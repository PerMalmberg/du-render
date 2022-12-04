package layout

import (
	"fmt"
	"math"
	"regexp"
	"strconv"
)

type Font struct {
	Font string  `json:"font,omitempty"`
	Size float32 `json:"size,omitempty"`
}

type Color struct {
	Red   float64
	Green float64
	Blue  float64
	Alpha float64
}

var colorReg = regexp.MustCompile(`^r(\d*\.?\d*),g(\d*\.?\d*),b(\d*\.?\d*),a(\d*\.?\d*)$`)

func (c *Color) UnmarshalText(data []byte) (err error) {
	s := string(data)
	colors := colorReg.FindStringSubmatch(s)

	if len(colors) != 5 {
		err = fmt.Errorf("cannot turn string into color: %v", s)
		return
	}

	c.Red, err = strconv.ParseFloat(colors[1], 64)

	if err != nil {
		return err
	}

	c.Green, err = strconv.ParseFloat(colors[2], 64)

	if err != nil {
		return err
	}

	c.Blue, err = strconv.ParseFloat(colors[3], 64)

	if err != nil {
		return err
	}

	c.Alpha, err = strconv.ParseFloat(colors[4], 64)

	if err != nil {
		return err
	}

	return nil
}

func (c Color) MarshalText() (text []byte, err error) {
	return []byte(fmt.Sprintf("r%0.3f,g%0.3f,b%0.3f,a%0.3f", c.Red, c.Green, c.Blue, c.Alpha)), nil
}

type ColorAndDistance struct {
	Color    Color   `json:"color,omitempty"`
	Distance float64 `json:"distance,omitempty"`
}

type Stroke struct {
	ColorAndDistance
}

type Shadow struct {
	ColorAndDistance
}

type Style struct {
	Align    *string  `json:"align,omitempty"`
	Stroke   *Stroke  `json:"stroke,omitempty"`
	Fill     *Color   `json:"fill,omitempty"`
	Rotation *float64 `json:"rotation,omitempty"`
	Shadow   *Shadow  `json:"shadow,omitempty"`
}

//var fontStype = regexp.MustCompile(`font-style:(.?);`)

func (s *Style) FromInlineCSS(style string) (err error) {
	// Extract the different parts from the Text property

	align := "h0,v1" // Left, Top, see RSAlightHor and RSAlignVer
	s.Align = &align

	if s.Fill, err = fillStyle(style); err != nil {
		return
	}

	if s.Stroke, err = stroke(style); err != nil {
		return
	}

	return
}

func roundToNearest(f float64, decimals int) float64 {
	p := math.Pow10(decimals)
	return math.Round(f*p) / p
}

func fillStyle(style string) (c *Color, err error) {
	var fillExp = regexp.MustCompile(`fill:#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})`)
	var fillOpacityExp = regexp.MustCompile(`fill-opacity:(\d*\.?\d*)`)
	return hexToColor(style, fillExp, fillOpacityExp)
}

func stroke(style string) (cd *Stroke, err error) {
	// stroke-linejoin:miter;stroke-linecap:butt;stroke-width:1;fill-opacity:0.55045873;fill:#28a745;stroke:#e02c9f;stroke-opacity:1
	var strokeExp = regexp.MustCompile(`stroke:#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})`)
	var strokeOpacityExp = regexp.MustCompile(`stroke-opacity:(\d*\.?\d*)`)
	var strokeWidthExp = regexp.MustCompile(`stroke-width:(\d*\.?\d*)`)
	var color *Color
	if color, err = hexToColor(style, strokeExp, strokeOpacityExp); err != nil || color == nil {
		return
	}

	distance := float64(0)
	widthVal := strokeWidthExp.FindStringSubmatch(style)
	if len(widthVal) == 2 {
		if distance, err = strconv.ParseFloat(widthVal[1], 32); err != nil {
			return
		}
	}

	cd = &Stroke{
		ColorAndDistance: ColorAndDistance{
			Color:    *color,
			Distance: distance,
		},
	}

	return
}

func hexToColor(style string, fillExp, opacityExp *regexp.Regexp) (c *Color, err error) {
	fillVal := fillExp.FindStringSubmatch(style)

	if len(fillVal) == 4 {
		var r, g, b int64
		if r, err = strconv.ParseInt(fillVal[1], 16, 0); err != nil {
			return
		}

		if g, err = strconv.ParseInt(fillVal[2], 16, 0); err != nil {
			return
		}

		if b, err = strconv.ParseInt(fillVal[3], 16, 0); err != nil {
			return
		}

		c = &Color{
			Red:   roundToNearest(float64(r), 3),
			Green: roundToNearest(float64(g), 3),
			Blue:  roundToNearest(float64(b), 3),
			Alpha: 1,
		}

		opacityVal := opacityExp.FindStringSubmatch(style)
		if len(opacityVal) == 2 {
			var a float64
			if a, err = strconv.ParseFloat(opacityVal[1], 32); err != nil {
				return
			}

			// Round to nearest, three decimal places
			c.Alpha = roundToNearest(a, 3)
		}
	}

	return
}

type MouseClick struct {
	Command string `json:"command,omitempty"`
}

type MouseInside struct {
	SetStyle string `json:"set_style"`
}

type Mouse struct {
	Click  MouseClick  `json:"mouse,omitempty"`
	Inside MouseInside `json:"inside,omitempty"`
}

type Component struct {
	Type         string  `json:"type,omitempty"`
	Layer        int     `json:"layer,omitempty"`
	Visible      bool    `json:"visible,omitempty"`
	Pos1         string  `json:"pos1,omitempty"`
	Pos2         string  `json:"pos2,omitempty"`
	CornerRadius float32 `json:"corner_radius,omitempty"`
	Style        string  `json:"style,omitempty"`
	Mouse        Mouse   `json:"mouse,omitempty"`
	Font         string  `json:"font,omitempty"`
	Text         string  `json:"text,omitempty"`
}

type Page struct {
	Components []Component `json:"components,omitempty"`
}

type Layout struct {
	Fonts  map[string]Font  `json:"fonts,omitempty"`
	Styles map[string]Style `json:"styles,omitempty"`
	Pages  map[string]Page  `json:"pages,omitempty"`
}
