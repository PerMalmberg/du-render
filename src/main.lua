local Props = require("Props")
local Color = require("Color")
local TextAlign = require("TextAlign")
local Font = require("Font")
local Screen = require("Screen")
local Vec2 = require("Vec2")

local screen = Screen.Instance()
local w, h = screen.Bounds():Unpack()

local goldenGlow = Props.New()
goldenGlow.Fill = Color.New(2, 1, 0)
goldenGlow.Align = TextAlign.New(RSAlignHor.Center, RSAlignVer.Middle)

local font = Font.Get(FontName.Montserrat, h * 0.05)

local layer = screen.Layer(1)
local background = layer.Image("assets.prod.novaquark.com/40794/9e363a3f-69d3-469e-adeb-3bf6d6d2db5c.jpg", Vec2.New(),
    Props.Default())
background.FillScreen()

layer.Text("Hello cruel world", Vec2.New(w / 2, h / 2), font, goldenGlow)

local box = layer.Box(Vec2.New(w / 4, h / 5), Vec2.New(w / 6, h / 6), 5, Props.Default())
box.Props.Fill = Color.New(1.1, 0, 0)


local greenGlow = Props.New()
greenGlow.Fill = Color.New(0, 2, 0)
greenGlow.Align = TextAlign.New(RSAlignHor.Left, RSAlignVer.Bottom)

local cost = layer.Text(string.format("%0.2f%%", screen.Stats()), Vec2.New(), font, greenGlow)
cost.Pos = Vec2.New(screen.Width() - cost.Width(), cost.Height())

screen.Render(1)
