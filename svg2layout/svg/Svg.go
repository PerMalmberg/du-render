package svg

import (
	"encoding/xml"
	"fmt"
	"strings"
)

type Style struct {
	XMLName xml.Name `xml:"style"`
	Id      string   `xml:"id,attr"`
	Text    string   `xml:",cdata"`
}

type PathEffect struct {
	XMLName xml.Name `xml:"path-effect"`
	Id      string   `xml:"id,attr"`
	Effect  string   `xml:"effect,attr"`
	Radius  float64  `xml:"radius,attr"`
}

type Defs struct {
	XMLName    xml.Name     `xml:"defs"`
	Id         string       `xml:"id,attr"`
	Style      []Style      `xml:"style"`
	PathEffect []PathEffect `xml:"path-effect"`
}

type Description struct {
	XMLName xml.Name `xml:"desc"`
	Text    string   `xml:",cdata"`
}

type MixedShape struct {
	Type  string
	Value interface{}
}

type PositionalShape struct {
	X     float64 `xml:"x,attr"`
	Y     float64 `xml:"y,attr"`
	Style string  `xml:"style,attr"`
}

type ShapeArea struct {
	PositionalShape
	Width  float64 `xml:"width,attr"`
	Height float64 `xml:"height,attr"`
}

type Rect struct {
	ShapeArea
	Description Description
	PathEffect  string `xml:"path-effect"`
}

type Span struct {
	PositionalShape
	Text        string `xml:",cdata"`
	Description Description
}

type Text struct {
	PositionalShape
	Text        []Span `xml:"tspan"`
	Description Description
}

type Circle struct {
	X           float32 `xml:"cx,attr"`
	Y           float32 `xml:"cy,attr"`
	Radius      float32 `xml:"r,attr"`
	Style       string  `xml:"style,attr"`
	Description Description
}

func (m *MixedShape) UnmarshalXML(d *xml.Decoder, start xml.StartElement) error {
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
	XMLName xml.Name     `xml:"g"`
	Shape   []MixedShape `xml:",any"`
}

type Svg struct {
	XMLName xml.Name `xml:"svg"`
	Width   float64  `xml:"width,attr"`
	Height  float64  `xml:"height,attr"`
	Defs    Defs     `xml:"defs"`
	Layer   []G      `xml:"g"`
}

func (svg *Svg) GetCornerRadiusById(id string) (float64, bool) {
	for _, v := range svg.Defs.PathEffect {
		if v.Id == strings.Trim(id, "#") {
			return v.Radius, true
		}
	}

	return 0, false
}
