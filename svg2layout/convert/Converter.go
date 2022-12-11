package convert

import (
	"bytes"
	"encoding/json"
	"encoding/xml"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"github.com/PerMalmberg/du-render/svg2layout/layout"
	"github.com/PerMalmberg/du-render/svg2layout/svg"
)

type IConverter interface {
	Convert() error
}

type converter struct {
	input            []string
	output           string
	fonts            IFonts
	result           layout.Layout
	commonStyles     map[string]*layout.Style
	pageStyleCounter int
}

func NewConverter(output string, inputs ...string) IConverter {
	return &converter{
		input:  inputs,
		output: output,
		fonts:  NewFonts(),
		result: layout.Layout{
			Fonts:  map[string]*layout.Font{},
			Styles: map[string]*layout.Style{},
			Pages:  map[string]*layout.Page{},
		},
		commonStyles:     map[string]*layout.Style{},
		pageStyleCounter: 0,
	}
}

func (c *converter) openFiles() (out *os.File, inp []*os.File, err error) {
	_ = os.Remove(c.output)
	out, err = os.OpenFile(c.output, os.O_CREATE|os.O_WRONLY, 0700)

	if err != nil {
		return
	}

	inp = []*os.File{}

	for _, curr := range c.input {
		f, err := os.Open(curr)
		if err != nil {
			break
		} else {
			inp = append(inp, f)
		}
	}

	// On error, close any opened files
	if err != nil {
		for _, v := range inp {
			v.Close()
		}

		out.Close()
	}

	fmt.Println("Opened files")

	return
}

func (c *converter) createFonts(image *svg.Svg) error {
	for _, layer := range image.Layer {
		for _, component := range layer.Shape {
			if text, ok := component.Value.(svg.Text); ok {
				defaultFont, _ := c.fonts.GetFont(text.Style)
				for _, span := range text.Span {
					if len(span.Span) > 0 {
						return fmt.Errorf("nested text spans not supported")
					}

					var selectedFont string
					selectedFont, substituted := c.fonts.GetFont(span.Style)
					if selectedFont != defaultFont && !substituted {
						c.fonts.UseFont(selectedFont)
					} else {
						c.fonts.UseFont(defaultFont)
						selectedFont = defaultFont
					}
				}
			}
		}
	}

	return nil
}

func (c *converter) createCommonStyles(pageName string, image *svg.Svg) (err error) {

	cssStyleExp := regexp.MustCompile(`(?s)\.([a-zA-Z0-9_-]+)\s*{(.*?)}`)

	// Parse styles from CSS
	for _, s := range image.Defs.Style {
		css := cssStyleExp.FindAllStringSubmatch(s.Text, -1)
		for _, v := range css {
			name := v[1]
			cssData := v[2]
			style := &layout.Style{}
			err = style.FromInlineCSS(cssData)
			if err != nil {
				return
			}

			fullName := c.createPageStyleName(pageName, name)
			fmt.Printf("Created common style: %s\n", fullName)
			c.commonStyles[fullName] = style
		}
	}

	return
}

func (c *converter) Convert() (err error) {
	out, inp, err := c.openFiles()

	if err != nil {
		return
	}

	defer func() {
		for _, f := range inp {
			f.Close()
		}

		out.Close()
	}()

	images := make(map[string]*svg.Svg)

	for _, f := range inp {
		fmt.Printf("Loading SVG image: %v", f.Name())
		var image *svg.Svg
		if image, err = ReadFileAsSvg(f); err != nil {
			return
		}

		name := filepath.Base(filepath.Clean(f.Name()))
		name = strings.Replace(name, filepath.Ext(f.Name()), "", -1)
		images[name] = image
	}

	for name, image := range images {
		fmt.Printf("Creating fonts from image %v\n", name)
		c.createFonts(image)
	}

	c.result.Fonts = c.fonts.GetUsedFonts()

	for name, image := range images {
		fmt.Printf("Converting image %v\n", name)
		if err = c.translateSvgToPage(name, image); err != nil {
			return
		}
	}

	c.replaceStyles()

	var outJson []byte
	if outJson, err = json.Marshal(c.result); err != nil {
		return
	}

	if _, err = out.Write(outJson); err != nil {
		return
	}

	fmt.Printf("Wrote output to %s\n", c.output)

	return
}

func (c *converter) createPageStyleName(pageName, styleName string) string {
	return fmt.Sprintf("%s-%s", pageName, styleName)
}

func (c *converter) translateSvgToPage(pageName string, image *svg.Svg) (err error) {
	if err = c.createCommonStyles(pageName, image); err != nil {
		return
	}

	c.pageStyleCounter = 0

	page := &layout.Page{}
	c.result.Pages[pageName] = page

	for layerId, layer := range image.Layer {
		layerId = layerId + 1
		for _, mix := range layer.Shape {
			if rect, ok := mix.Value.(svg.Rect); ok {
				pos2 := fmt.Sprintf("(%0.3f,%0.3f)", rect.X+rect.Width, rect.Y+rect.Height)

				comp := layout.Component{
					Type:    "box",
					Visible: true,
					Layer:   layerId,
					Pos1:    fmt.Sprintf("(%0.3f,%0.3f)", rect.X, rect.Y),
					Pos2:    &pos2,
				}

				if radius, ok := image.GetCornerRadiusById(rect.PathEffect); ok {
					comp.CornerRadius = &radius
				}

				if err = c.processComponentStyle(&comp, &rect.StyledShape, pageName); err != nil {
					return
				}

				c.parseBindings(&comp, rect.Description.Text)

				page.Components = append(page.Components, comp)

			} else if text, ok := mix.Value.(svg.Text); ok {
				// Text is in first span. We only support one span per text.
				if len(text.Span) != 1 {
					err = errors.New("only a single span may exist in a text")
					return
				}

				for _, span := range text.Span {
					comp := layout.Component{
						Type:    "text",
						Layer:   layerId,
						Visible: true,
						Pos1:    fmt.Sprintf("(%0.3f,%0.3f)", span.X, span.Y),
						Text:    &span.Text,
					}

					font, _ := c.fonts.GetFont(text.Style)
					comp.Font = &font

					if err = c.processComponentStyle(&comp, &text.StyledShape, pageName); err != nil {
						return
					}

					// Bindings taken from top-level text element
					c.parseBindings(&comp, text.Description.Text)

					page.Components = append(page.Components, comp)

				}
			} else if circle, ok := mix.Value.(svg.Circle); ok {
				comp := layout.Component{
					Type:    "circle",
					Layer:   layerId,
					Visible: true,
					Pos1:    fmt.Sprintf("(%0.3f,%0.3f)", circle.X, circle.Y),
					Radius:  &circle.Radius,
				}

				if err = c.processComponentStyle(&comp, &circle.StyledShape, pageName); err != nil {
					return
				}

				c.parseBindings(&comp, circle.Description.Text)

				page.Components = append(page.Components, comp)
			}
		}
	}

	return
}

func (c *converter) processComponentStyle(comp *layout.Component, shape *svg.StyledShape, pageName string) (err error) {
	// A component may reference a common style and have local in-line style attributes.
	local := &layout.Style{}
	err = local.FromInlineCSS(shape.Style)
	if err != nil {
		return
	}

	err = c.setComponentStyle(local, comp, shape, pageName)
	if err != nil {
		return
	}

	return
}

func (c *converter) replaceStyles() {
	// Find styles that are equal and replace the use of them on components with a single instance
	replacement := make(map[string]*string)

	// Add common styles to local ones ensure they are all merged
	for name, style := range c.commonStyles {
		c.result.Styles[name] = style
	}

	keys := make([]string, 0, len(c.result.Styles))
	for k := range c.result.Styles {
		keys = append(keys, k)
	}

	sort.Slice(keys, func(i, j int) bool {
		return keys[i] < keys[j]
	})

	for outerIx := 0; outerIx < len(keys); outerIx++ {
		for innerIx := 0; innerIx < len(keys); innerIx++ {
			outerName := keys[outerIx]
			innerName := keys[innerIx]
			if outerName == innerName {
				continue
			}

			selected, replaced := c.prioritizeCommonStyle(outerName, innerName)

			if _, found := replacement[selected]; found {
				continue
			}

			if c.result.Styles[outerName].Equals(c.result.Styles[innerName]) {
				fmt.Printf("Replacing style %s with %s\n", replaced, selected)
				replacement[replaced] = &selected
			}
		}
	}

	// Loop components and update styles to use the replacements.
	for _, page := range c.result.Pages {
		for _, comp := range page.Components {
			if comp.Style != nil {
				if repl, found := replacement[*comp.Style]; found {
					comp.Style = repl
				}
			}
		}
	}

	for k := range replacement {
		delete(c.result.Styles, k)
		fmt.Printf("Removed style %s\n", k)
	}
}

func (c *converter) prioritizeCommonStyle(a, b string) (selected, merged string) {
	if _, exists := c.commonStyles[a]; exists {
		return a, b
	} else if _, exists = c.commonStyles[b]; exists {
		return b, a
	}
	return a, b
}

func (c *converter) setComponentStyle(local *layout.Style, comp *layout.Component, styled *svg.StyledShape, pageName string) (err error) {
	// Get all common names
	styleNames := strings.Split(strings.Trim(styled.Class, " "), " ")
	for i := 0; i < len(styleNames); i++ {
		if styleNames[i] != "" {
			styleNames[i] = c.createPageStyleName(pageName, styleNames[i])
		}
	}

	// Merge into the local style
	for _, referencedStyle := range styleNames {
		if referencedStyle != "" {
			commonStyle, ok := c.commonStyles[referencedStyle]
			if !ok {
				err = fmt.Errorf("unknown referenced style: %s", referencedStyle)
				return
			} else {
				local.MergeInto(commonStyle)
			}
		}
	}

	componentStyleName := fmt.Sprintf("%s-%d", c.createPageStyleName(pageName, comp.Type), c.pageStyleCounter)
	c.pageStyleCounter++
	fmt.Printf("Created component style: %s\n", componentStyleName)
	comp.Style = &componentStyleName
	c.result.Styles[componentStyleName] = local

	return
}

func (c *converter) parseBindings(comp *layout.Component, potentialBindings string) {
	// Bindings are expected to have this format:
	// propertyName:$keyword(...) where propertyName is the lower-case name used in the Json layout.
	exp := regexp.MustCompile(`^([a-z0-9]+):(\$[a-zA-Z0-9]+\(.+?\))$`)

	comp.Bindings = make(map[string]string)

	for _, part := range strings.Split(potentialBindings, "\n") {
		bindings := exp.FindAllStringSubmatch(part, -1)

		for _, v := range bindings {
			property := v[1]
			binding := v[2]
			comp.Bindings[property] = binding
		}
	}
}

func ReadFileAsSvg(file *os.File) (image *svg.Svg, err error) {
	b := bytes.NewBuffer(nil)
	file.Seek(0, 0)
	_, err = io.Copy(b, file)
	if err != nil {
		return
	}

	image = &svg.Svg{}
	err = xml.Unmarshal(b.Bytes(), image)

	if image.Width != 1024 || image.Height != 613 {
		err = fmt.Errorf("dimensions must be 1024x613, as per DU specifications. Image is %fx%f", image.Width, image.Height)
		return
	}

	return
}
