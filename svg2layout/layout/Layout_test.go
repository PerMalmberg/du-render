package layout

import (
	"encoding/json"
	"strconv"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestColor(t *testing.T) {

	type TestType struct {
		Color Color `json:"color"`
	}

	var test TestType
	err := json.Unmarshal([]byte(`{ "color": "r0.700,g1,b0.9,a0.5" }`), &test)
	assert.NoError(t, err)
	assert.Equal(t, 0.7, test.Color.Red)
	assert.Equal(t, float64(1), test.Color.Green)
	assert.Equal(t, 0.9, test.Color.Blue)
	assert.Equal(t, 0.5, test.Color.Alpha)

	data, err := json.Marshal(test)
	assert.NoError(t, err)
	assert.Equal(t, `{"color":"r0.700,g1.000,b0.900,a0.500"}`, string(data))
}

func toDURgb(v int64) float64 {
	return RoundToNearest(float64(v)/255.0, 3)
}

func TestFill(t *testing.T) {
	style := "fill:#28a745;fill-opacity:0.5655;stroke-width:0.132293;stroke-linecap:butt;stroke-linejoin:miter"

	c, err := FillFromStyle(style)
	assert.NoError(t, err)
	r, _ := strconv.ParseInt("28", 16, 0)
	assert.EqualValues(t, toDURgb(r), c.Red)
	g, _ := strconv.ParseInt("a7", 16, 0)
	assert.EqualValues(t, toDURgb(g), c.Green)
	b, _ := strconv.ParseInt("45", 16, 0)
	assert.EqualValues(t, toDURgb(b), c.Blue)
	assert.EqualValues(t, 0.566, c.Alpha)
}

func TestStroke(t *testing.T) {
	style := "stroke-linejoin:miter;stroke-linecap:butt;stroke-width:3;fill-opacity:0.55045873;fill:#28a745;stroke:#e02c9f;stroke-opacity:1"

	cd, err := StrokeFromStyle(style)
	assert.NoError(t, err)
	r, _ := strconv.ParseInt("e0", 16, 0)
	assert.EqualValues(t, toDURgb(r), cd.Color.Red)
	g, _ := strconv.ParseInt("2c", 16, 0)
	assert.EqualValues(t, toDURgb(g), cd.Color.Green)
	b, _ := strconv.ParseInt("9f", 16, 0)
	assert.EqualValues(t, toDURgb(b), cd.Color.Blue)
	assert.EqualValues(t, 1, cd.Color.Alpha)
	assert.EqualValues(t, 3, cd.Distance)
}

func TestStyleFromInlineCSS(t *testing.T) {
	style := `stroke-linejoin:miter;stroke-linecap:butt;stroke-width:1;fill-opacity:0.55045873;fill:#28a745;stroke:#e02c9f;stroke-opacity:0.2`
	s := Style{}
	assert.NoError(t, s.FromInlineCSS(style))
	assert.EqualValues(t, 0.550, s.Fill.Alpha)
	assert.EqualValues(t, 0.2, s.Stroke.Color.Alpha)
	assert.Nil(t, s.Shadow) // Not supported in SVG
}

func TestSyleComparison(t *testing.T) {
	s1 := Style{
		Align:    new(string),
		Stroke:   &Stroke{},
		Fill:     &Color{},
		Rotation: new(float64),
	}

	s2 := Style{
		Align:    new(string),
		Stroke:   &Stroke{},
		Fill:     &Color{},
		Rotation: new(float64),
	}

	assert.Equal(t, s1, s2)
	*s2.Align = "foo"
	assert.False(t, s1.Equals(&s2))
	*s1.Align = "foo"
	assert.True(t, s1.Equals(&s2))
	s2.Shadow = &Shadow{}
	s2.Shadow.Color = Color{
		Red:   1,
		Green: 2,
		Blue:  3,
		Alpha: 4,
	}
	assert.False(t, s1.Equals(&s2))
	s1.Shadow = &Shadow{}
	s1.Shadow.Color = Color{
		Red:   1,
		Green: 2,
		Blue:  3,
		Alpha: 4,
	}
	assert.True(t, s1.Equals(&s2))
}
