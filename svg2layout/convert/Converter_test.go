package convert

import (
	"encoding/json"
	"os"
	"strings"
	"testing"

	"github.com/PerMalmberg/du-render/svg2layout/svg"
	"github.com/stretchr/testify/assert"
)

func TestOpenFiles(t *testing.T) {
	c := NewConverter("./test_out", "./a", "./b").(*converter)
	output, input, err := c.openFiles()
	assert.NoError(t, err)
	assert.NotNil(t, output)
	assert.NotNil(t, input)
	os.Remove("./test_out")
}

func TestReadFileAsSvg(t *testing.T) {
	f, err := os.Open("../test_data/desc.svg")
	assert.NoError(t, err)
	defer func() {
		f.Close()
	}()

	data, err := ReadFileAsSvg(f)
	assert.NoError(t, err)
	assert.EqualValues(t, 1024, data.Width)
	assert.EqualValues(t, 613, data.Height)
	assert.Contains(t, data.Defs.Style[0].Text, ".common")
	assert.Equal(t, 2, len(data.Layer))
	assert.Equal(t, 6, len(data.Layer[0].Shape))
	assert.Equal(t, 1, len(data.Layer[1].Shape))

	textDescFound := false
	rectDescFound := false
	circleDescFound := false
	commonClassFound := false
	for _, layer := range data.Layer {
		for _, s := range layer.Shape {
			if text, ok := s.Value.(svg.Text); ok {
				textDescFound = textDescFound || strings.Contains(text.Description.Text, "binding goes here for text")
			} else if rect, ok := s.Value.(svg.Rect); ok {
				rectDescFound = rectDescFound || strings.Contains(rect.Description.Text, "pos1:$vec2(path{gauge/fuel:value}:init{(248,611)}:interval{0.1}:percent{(248,2)})")
				commonClassFound = commonClassFound || rect.Class == "common"
			} else if circle, ok := s.Value.(svg.Circle); ok {
				circleDescFound = circleDescFound || strings.Contains(circle.Description.Text, "circle also has a binding")
			}
		}
	}
	assert.True(t, textDescFound)
	assert.True(t, rectDescFound)
	assert.True(t, circleDescFound)
	assert.True(t, commonClassFound)
}

func TestConvertPage(t *testing.T) {
	f, err := os.Open("../test_data/desc.svg")
	assert.NoError(t, err)
	defer func() {
		f.Close()
	}()

	image, err := ReadFileAsSvg(f)
	assert.NoError(t, err)

	c := NewConverter("").(*converter)
	err = c.translateSvgToPage("pageName", image)
	page := c.result.Pages["pageName"]
	assert.NoError(t, err)
	assert.Equal(t, 7, len(page.Components))

	j, err := json.Marshal(page)
	assert.NoError(t, err)
	data := string(j)
	assert.Contains(t, data, `"type":"circle"`)
	assert.Contains(t, data, `$vec2(path{gauge/fuel:value}:init{(248,611)}:interval{0.1}:percent{(248,2)})`)

	assert.Equal(t, 7, len(c.result.Styles))
	assert.NotContains(t, c.result.Styles, "pageName-common")
	assert.NotContains(t, c.result.Styles, "pageName-pink1")
	c.replaceStyles()
	assert.Equal(t, 7, len(c.result.Styles))
	assert.Contains(t, c.result.Styles, "pageName-common")
	assert.Contains(t, c.result.Styles, "pageName-pink1")

}

func TestCreateFonts(t *testing.T) {
	f, err := os.Open("../test_data/desc.svg")
	assert.NoError(t, err)
	defer func() {
		f.Close()
	}()

	image, err := ReadFileAsSvg(f)
	assert.NoError(t, err)

	c := NewConverter("").(*converter)
	assert.NoError(t, c.createFonts(image))
	used := c.fonts.GetUsedFonts()
	assert.EqualValues(t, 1, len(used))
	usedFont, ok := used["Montserrat-4"]
	assert.True(t, ok)
	assert.Equal(t, "Montserrat", usedFont.Font)
	assert.Equal(t, 4, usedFont.Size)
}

func TestSyleMerging(t *testing.T) {
	f, err := os.Open("../test_data/desc.svg")
	assert.NoError(t, err)
	defer func() {
		f.Close()
	}()

}
