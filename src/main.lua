local Props = require("Props")
local Color = require("Color")
local TextAlign = require("TextAlign")
local Font = require("Font")
local Screen = require("Screen")

local screen = Screen.Instance()
local w, h = screen.Bounds():Unpack()

local goldenGlow = Props.New()
goldenGlow.Fill = Color.New(2, 1, 0)
goldenGlow.Align = TextAlign.New(RSAlignHor.Center, RSAlignVer.Middle)

local greenGlow = Props.New()
greenGlow.Fill = Color.New(0, 2, 0)
greenGlow.Align = TextAlign.New(RSAlignHor.Center, RSAlignVer.Middle)

local font = Font.Get(FontName.Montserrat, h * 0.05)

local layer = screen.Layer(1)
layer.Text("Hello cruel world", w / 2, h / 2, font, goldenGlow)
local rotatedLayer = screen.Layer(2)
rotatedLayer.Rotation = 45
rotatedLayer.Origin = screen.Bounds() / 2

rotatedLayer.Text(string.format("%0.2f%%", screen.Stats()), w / 2, h / 2, font, greenGlow)

screen.Render(1)
