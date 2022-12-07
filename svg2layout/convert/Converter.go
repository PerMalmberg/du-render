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
	input  []string
	output string
	fonts  IFonts
}

func NewConverter(output string, inputs ...string) IConverter {
	return &converter{
		input:  inputs,
		output: output,
		fonts:  NewFonts(),
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

func (c *converter) createStyles(image *svg.Svg) {

	// Create styles from css
	/* for _, style := range image.Defs.Style {
		style.Text
	} */

	// Loop components
	// Create styles based on the style data
	// Merge styles
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

	result := layout.Layout{}

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

	for name, image := range images {
		fmt.Printf("Creating styles from image %v\n", name)
		c.createStyles(image)
	}

	for name, image := range images {
		fmt.Printf("Converting image %v\n", name)
		var page *layout.Page
		page, err = c.translateSvgToPage(image)

		if err != nil {
			return
		}

		result.Pages[name] = page

	}

	return
}

func (c *converter) translateSvgToPage(image *svg.Svg) (page *layout.Page, err error) {
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
