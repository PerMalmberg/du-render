package convert

import (
	"bytes"
	"encoding/xml"
	"fmt"
	"io"
	"os"
	"regexp"
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
		pageStyleCounter: 0,
	}
}

func (c *converter) openFiles() (out *os.File, inp []*os.File, err error) {
	out, err = os.OpenFile(c.output, os.O_CREATE, 0655)

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

	cssStyleExp := regexp.MustCompile(`\.([a-zA-Z0-9_-]+)\s*{(.*)}`)

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

			c.result.Styles[c.createPageStyleName(pageName, name)] = style
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

		images[f.Name()] = image
	}

	for name, image := range images {
		fmt.Printf("Creating fonts from image %v\n", name)
		c.createFonts(image)
	}

	c.result.Fonts = c.fonts.GetUsedFonts()

	for name, image := range images {
		fmt.Printf("Converting image %v\n", name)
		var page *layout.Page
		page, err = c.translateSvgToPage(name, image)

		if err != nil {
			return
		}

		c.result.Pages[name] = page

	}

	return
}

func (c *converter) createPageStyleName(pageName, styleName string) string {
	return fmt.Sprintf("%s-%s", pageName, styleName)
}

func (c *converter) translateSvgToPage(pageName string, image *svg.Svg) (page *layout.Page, err error) {
	if err = c.createCommonStyles(pageName, image); err != nil {
		return
	}

	c.pageStyleCounter = 0

	page = &layout.Page{}

	for layerId, layer := range image.Layer {
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

				// A component may reference a common style and have local in-line style attributes.
				local := &layout.Style{}
				err = local.FromInlineCSS(rect.Style)
				if err != nil {
					return
				}

				err = c.setComponentStyle(local, &comp, &rect.StyledShape, pageName)
				if err != nil {
					return
				}

				c.parseBindings(&comp, rect.Description.Text)

				page.Components = append(page.Components, comp)

			} else if /*text,*/ _, ok := mix.Value.(svg.Text); ok {
				// Create from the tspans
			} else if circle, ok := mix.Value.(svg.Circle); ok {
				comp := layout.Component{
					Type:    "circle",
					Layer:   layerId,
					Visible: true,
					Pos1:    fmt.Sprintf("(%0.3f,%0.3f)", circle.X, circle.Y),
					Radius:  &circle.Radius,
				}

				c.parseBindings(&comp, circle.Description.Text)

				page.Components = append(page.Components, comp)
			}
		}
	}

	c.mergeStyles()

	return
}

func (c *converter) mergeStyles() {
	// Find styles that are equal and replace the use of them on components with a single instance
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
			commonStyle, ok := c.result.Styles[referencedStyle]
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
