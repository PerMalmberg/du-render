package convert

import (
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
	assert.Contains(t, data.Defs.Style.Text, ".class")
	assert.Equal(t, 3, len(data.G.Shape))

	textDesccFound := false
	rectDescFound := false
	circleDescFound := false
	for _, s := range data.G.Shape {
		if text, ok := s.Value.(svg.Text); ok {
			textDesccFound = strings.Contains(text.Description.Text, "bindings goes here")
		} else if rect, ok := s.Value.(svg.Rect); ok {
			rectDescFound = strings.Contains(rect.Description.Text, "this also has bindings")
		} else if circle, ok := s.Value.(svg.Circle); ok {
			circleDescFound = strings.Contains(circle.Description.Text, "circle also has a binding")
		}
	}

	assert.True(t, textDesccFound)
	assert.True(t, rectDescFound)
	assert.True(t, circleDescFound)
}
