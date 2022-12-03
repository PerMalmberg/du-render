package layout

import (
	"encoding/json"
	"fmt"
	"os"
	"testing"

	"github.com/PerMalmberg/du-render/svg2layout/convert"
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

func TestConvertSvgStyleToJson(t *testing.T) {
	f, err := os.Open("../test_data/layout.svg")
	assert.NoError(t, err)
	svg, err := convert.ReadFileAsSvg(f)
	assert.NoError(t, err)

	json, err := json.Marshal(svg.Defs.Style)
	assert.NoError(t, err)
	fmt.Print(string(json))
}
