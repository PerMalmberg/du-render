package convert

import (
	"encoding/xml"
	"fmt"

	"github.com/PerMalmberg/du-render/svg2layout/layout"
)

type Style struct {
	XMLName xml.Name `xml:"style"`
	Id      string   `xml:"id,attr"`
	Text    string   `xml:",cdata"`
}

func (s Style) MarshalJSON() (data []byte, err error) {
	var target layout.Style

	// Extract the different parts from the Text property
	// font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:9.04774px;font-family:'Courier New';-inkscape-font-specification:'Courier New';fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:0.180955;stroke-linecap:butt;stroke-linejoin:miter;stroke-dasharray:none;stroke-opacity:1

	target.Align = "h0,v1" // Left, Top, see RSAlightHor and RSAlignVer

	// fill:#000000;fill-opacity:1
	target.Fill = layout.Color{
		Red:   0,
		Green: 0,
		Blue:  0,
		Alpha: 0,
	}
}

type Defs struct {
	XMLName xml.Name `xml:"defs"`
	Id      string   `xml:"id,attr"`
	Style   Style    `xml:"style"`
}

type Shape struct {
	Type  string
	Value interface{}
}

type PositionalShape struct {
	X     float32 `xml:"x,attr"`
	Y     float32 `xml:"y,attr"`
	Style string  `xml:"style,attr"`
}

type ShapeArea struct {
	PositionalShape
	Width  string `xml:"width,attr"`
	Height string `xml:"height,attr"`
}

type Rect struct {
	ShapeArea
}

type Span struct {
	PositionalShape
	Text string `xml:",cdata"`
}

type Text struct {
	PositionalShape
	Text []Span `xml:"tspan"`
}

type Circle struct {
	X      float32 `xml:"cx,attr"`
	Y      float32 `xml:"cy,attr"`
	Radius float32 `xml:"r,attr"`
	Style  string  `xml:"style,attr"`
}

func (m *Shape) UnmarshalXML(d *xml.Decoder, start xml.StartElement) error {
	switch start.Name.Local {
	case "text":
		var e Text
		if err := d.DecodeElement(&e, &start); err != nil {
			return err
		}
		m.Value = e
		m.Type = start.Name.Local
	case "rect":
		var e Rect
		if err := d.DecodeElement(&e, &start); err != nil {
			return err
		}
		m.Value = e
		m.Type = start.Name.Local
	case "circle":
		var e Circle
		if err := d.DecodeElement(&e, &start); err != nil {
			return err
		}
		m.Value = e
		m.Type = start.Name.Local
	default:
		return fmt.Errorf("unknown element: %s", start)
	}
	return nil
}

type G struct {
	XMLName xml.Name `xml:"g"`
	Shape   []Shape  `xml:",any"`
}

type Svg struct {
	XMLName xml.Name `xml:"svg"`
	Width   string   `xml:"width,attr"`
	Height  string   `xml:"height,attr"`
	Defs    Defs     `xml:"defs"`
	G       G        `xml:"g"`
}
