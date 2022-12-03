package convert

import (
	"os"
	"testing"

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
	f, err := os.Open("../test_data/layout.svg")
	assert.NoError(t, err)
	defer func() {
		f.Close()
	}()

	svg, err := ReadFileAsSvg(f)
	assert.NoError(t, err)
	assert.Equal(t, "1024", svg.Width)
	assert.Equal(t, "613", svg.Height)
	assert.Contains(t, svg.Defs.Style.Text, ".class")
	assert.Equal(t, 48, len(svg.G.Shape))
}
