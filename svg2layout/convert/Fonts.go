package convert

import (
	"fmt"
	"math"
	"regexp"
	"strconv"
	"strings"

	"github.com/PerMalmberg/du-render/svg2layout/layout"
)

type FontVariant struct {
	Bold    bool
	Light   bool
	Regular bool
}

type IFonts interface {
	GetFont(style string) (name string, substituted bool)
	UseFont(name string)
	GetUsedFonts() map[string]*layout.Font
}

type fonts struct {
	allowed map[string]FontVariant
	current map[string]*layout.Font
	used    map[string]*layout.Font
}

var defaultFont = "RobotoMono"
var defaultSize = 10

func NewFonts() IFonts {
	f := &fonts{
		allowed: map[string]FontVariant{},
		current: map[string]*layout.Font{},
		used:    map[string]*layout.Font{},
	}

	f.allowed["FiraMono"] = FontVariant{
		Bold:    true,
		Light:   false,
		Regular: true,
	}

	f.allowed["Montserrat"] = FontVariant{
		Bold:    true,
		Light:   true,
		Regular: true,
	}

	f.allowed["Play"] = FontVariant{
		Bold:    true,
		Light:   false,
		Regular: true,
	}

	f.allowed["RefrigeratorDeluxe"] = FontVariant{
		Bold:    false,
		Light:   true,
		Regular: true,
	}

	f.allowed["RobotoCondensed"] = FontVariant{
		Bold:    false,
		Light:   false,
		Regular: true,
	}

	f.allowed["RobotoMono"] = FontVariant{
		Bold:    true,
		Light:   false,
		Regular: true,
	}

	return f
}

func (f *fonts) GetUsedFonts() map[string]*layout.Font {
	return f.used
}

func (f *fonts) GetFont(style string) (name string, substituted bool) {
	// Extract font-family, font-weight and font-size
	// Round font size to nearest integer
	// Match against the allowed fonts
	// Find existing font with same attributes or add new
	// font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:6.03182px;font-family:monospace;-inkscape-font-specification:monospace;fill:#000000;stroke:none;stroke-width:0.180955
	fontSizeExp := regexp.MustCompile(`font-size:(\d*\.?\d*)px`)
	fontFamilyExp := regexp.MustCompile(`font-family:(.+?)(?:;|$)`)
	fontWeightExp := regexp.MustCompile(`font-weight:(.+?)(?:;|$)`)
	inkscapeFontSpecExp := regexp.MustCompile(`-inkscape-font-specification:'(.+?)'`)

	size := fontSizeExp.FindStringSubmatch(style)
	family := fontFamilyExp.FindStringSubmatch(style)
	weight := fontWeightExp.FindStringSubmatch(style)
	fontSpec := inkscapeFontSpecExp.FindStringSubmatch(style)

	bold := false
	light := false

	if fontSpec != nil {
		bold = strings.HasSuffix(fontSpec[1], "Bold")
		light = strings.HasSuffix(fontSpec[1], "Light")
	}

	if weight != nil {
		if !bold {
			bold = weight[1] == "bold"
		}

		if !light {
			bold = weight[1] == "light"
		}
	}

	if size != nil {
		fSize, err := strconv.ParseFloat(size[1], 32)
		if err != nil {
			fSize = float64(defaultSize)
		}
		return f.getFont(family[1], bold, light, fSize)
	}

	return f.getFont(defaultFont, false, false, float64(defaultSize))
}

func (f *fonts) UseFont(name string) {
	f.used[name] = f.current[name]
}

func (f *fonts) getFont(family string, bold, light bool, size float64) (key string, substituted bool) {
	allowed, found := f.allowed[family]
	substituted = false
	name := family

	if found {
		if !bold && !light && allowed.Regular {
			name = family
		} else if bold && allowed.Bold {
			name = fmt.Sprintf("%s-Bold", family)
		} else if light && allowed.Light {
			name = fmt.Sprintf("%s-Light", family)
		} else {
			substituted = true
		}
	} else {
		substituted = true
	}

	if substituted {
		fmt.Printf("No matching attributes for font '%s': bold: %v, light: %v, using default %s with size %d\n", family, bold, light, defaultFont, defaultSize)
		name = defaultFont
		size = float64(defaultSize)
		bold = false
		light = false
	}

	fontSize := int(math.Round(size))
	key = fmt.Sprintf("%s-%d", name, fontSize)

	_, ok := f.current[key]

	if !ok {
		font := &layout.Font{
			Font: name,
			Size: fontSize,
		}
		f.current[key] = font
		fmt.Printf("Created font: %s", key)
	}

	return
}
