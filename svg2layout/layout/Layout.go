package layout

import (
	"fmt"
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
	Distance float32 `json:"distance,omitempty"`
}

type Stroke struct {
	ColorAndDistance
}

type Shadow struct {
	ColorAndDistance
}

type Style struct {
	Align    string  `json:"align,omitempty"`
	Stroke   Stroke  `json:"stroke,omitempty"`
	Fill     Color   `json:"fill,omitempty"`
	Rotation float32 `json:"rotation,omitempty"`
	Shadow   Shadow  `json:"shadow,omitempty"`
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
