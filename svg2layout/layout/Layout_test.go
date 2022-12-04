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

func TestFill(t *testing.T) {
	style := "fill:#28a745;fill-opacity:0.5655;stroke-width:0.132293;stroke-linecap:butt;stroke-linejoin:miter"

	c, err := fillStyle(style)
	assert.NoError(t, err)
	r, _ := strconv.ParseInt("28", 16, 0)
	assert.EqualValues(t, r, c.Red)
	g, _ := strconv.ParseInt("a7", 16, 0)
	assert.EqualValues(t, g, c.Green)
	b, _ := strconv.ParseInt("45", 16, 0)
	assert.EqualValues(t, b, c.Blue)
	assert.EqualValues(t, 0.566, c.Alpha)
}

func TestStroke(t *testing.T) {
	style := "stroke-linejoin:miter;stroke-linecap:butt;stroke-width:3;fill-opacity:0.55045873;fill:#28a745;stroke:#e02c9f;stroke-opacity:1"

	cd, err := stroke(style)
	assert.NoError(t, err)
	r, _ := strconv.ParseInt("e0", 16, 0)
	assert.EqualValues(t, r, cd.Color.Red)
	g, _ := strconv.ParseInt("2c", 16, 0)
	assert.EqualValues(t, g, cd.Color.Green)
	b, _ := strconv.ParseInt("9f", 16, 0)
	assert.EqualValues(t, b, cd.Color.Blue)
	assert.EqualValues(t, 1, cd.Color.Alpha)
	assert.EqualValues(t, 3, cd.Distance)
}

func TestStyleFromInlineCSS(t *testing.T) {
	style := `stroke-linejoin:miter;stroke-linecap:butt;stroke-width:1;fill-opacity:0.55045873;fill:#28a745;stroke:#e02c9f;stroke-opacity:0.2`
	s := Style{}
	assert.NoError(t, s.FromInlineCSS(style))
	assert.EqualValues(t, 0.550, s.Fill.Alpha)
	assert.EqualValues(t, 0.2, s.Stroke.Color.Alpha)
	assert.Nil(t, s.Shadow)
}
