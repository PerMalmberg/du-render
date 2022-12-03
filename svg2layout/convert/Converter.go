package convert

import (
	"bytes"
	"encoding/xml"
	"io"
	"os"
)

type IConverter interface {
	Convert() error
}

type converter struct {
	input  []string
	output string
}

func NewConverter(output string, inputs ...string) IConverter {
	return &converter{
		input:  inputs,
		output: output,
	}
}

func (c *converter) openFiles() (out *os.File, inp []*os.File, err error) {
	out, err = os.OpenFile(c.output, os.O_CREATE, 0655)

	if err != nil {
		return
	}

	inp = []*os.File{}

	for _, curr := range c.input {
		f, err := os.Open(curr)
		if err != nil {
			break
		} else {
			inp = append(inp, f)
		}
	}

	// On error, close any opened files
	if err != nil {
		for _, v := range inp {
			v.Close()
		}

		out.Close()
	}

	return
}

func (c *converter) Convert() (err error) {
	//inp, out, err := c.openFiles()

	if err != nil {
		return
	}

	//inSvg := c.readFilesAsSvg(inp)

	return
}

func ReadFileAsSvg(file *os.File) (svg Svg, err error) {
	b := bytes.NewBuffer(nil)
	_, err = io.Copy(b, file)
	if err != err {
		return
	}

	err = xml.Unmarshal(b.Bytes(), &svg)
	return
}
