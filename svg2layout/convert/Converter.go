package convert

import (
	"bytes"
	"encoding/xml"
	"fmt"
	"io"
	"os"
	"regexp"

	"github.com/PerMalmberg/du-render/svg2layout/layout"
	"github.com/PerMalmberg/du-render/svg2layout/svg"
)

type IConverter interface {
	Convert() error
}

type converter struct {
	input  []string
	output string
}

func NewConverter(output string, inputs ...string) IConverter {
	return &converter{
		input:  inputs,
		output: output,
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

	for _, f := range inp {
		var image *svg.Svg
		if image, err = ReadFileAsSvg(f); err != nil {
			return
		}

		page := layout.Page{}

		err = c.translateSvgToPage(image, &page)

		if err != nil {
			return
		}

		result.Pages[f.Name()] = page

	}

	return
}

func (c *converter) translateSvgToPage(image *svg.Svg, page *layout.Page) (err error) {
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

				c.createBindings(&comp, rect.Description.Text)

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

				c.createBindings(&comp, circle.Description.Text)

				page.Components = append(page.Components, comp)
			}
		}
	}

	return
}

func (c *converter) createBindings(comp *layout.Component, potentialBindings string) {
	// Bindings are expected to have this format:
	// PropertyName:$keyword(...)
	exp := regexp.MustCompile(`([a-zA-Z0-9]+):(\$[a-zA-Z0-9]+\(.+?\))`)
	bindings := exp.FindAllStringSubmatch(potentialBindings, -1)

	/// QQQ Can we assign these to the final JSON?
	comp.Bindings = make(map[string]string)
	for _, v := range bindings {
		property := v[1]
		binding := v[2]
		comp.Bindings[property] = binding
	}
}

func ReadFileAsSvg(file *os.File) (image *svg.Svg, err error) {
	b := bytes.NewBuffer(nil)
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
