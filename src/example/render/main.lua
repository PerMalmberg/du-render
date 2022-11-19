local Props = require("native/Props")
local Color = require("native/Color")
local TextAlign = require("native/TextAlign")
local Font = require("native/Font")
local Screen = require("native/Screen")
local Vec2 = require("native/Vec2")
local ColorAndDistance = require("native/ColorAndDistance")

local screen = Screen.Instance()
local screenDim = screen.Bounds()
local w, h = screenDim:Unpack()

local goldenGlow = Props.New()
goldenGlow.Fill = Color.New(2, 1, 0)
goldenGlow.Align = TextAlign.New(RSAlignHor.Center, RSAlignVer.Middle)

local font = Font.Get(FontName.Montserrat, h * 0.05)

local layer = screen.Layer(1)
local background = layer.Image("assets.prod.novaquark.com/40794/9e363a3f-69d3-469e-adeb-3bf6d6d2db5c.jpg", Vec2.New(),
    Props.Default())
background.FillScreen()


local box = layer.Box(Vec2.New(w / 4, h / 5), Vec2.New(w / 6, h / 6), 5, Props.Default())
box.Props.Fill = Color.New(1.1, 0, 0)
box.Props.Shadow = ColorAndDistance.New(Color.New(0, 1, 0), 50)
box.Props.Rotation = math.deg(math.sin(screen.TimeSinceStart()))
box.Props.Stroke = ColorAndDistance.New(Color.New(0, 0, 1), 25)

local greenGlow = Props.New()
greenGlow.Fill = Color.New(0, 2, 0)
greenGlow.Align = TextAlign.New(RSAlignHor.Left, RSAlignVer.Bottom)

local cost = layer.Text(string.format("%0.2f%%", screen.Stats()), Vec2.New(), font, greenGlow)
cost.Pos = Vec2.New(screen.Width() - cost.Width(), cost.Height())

local circle = layer.Circle(screenDim * 0.75, 20)
circle.Props.Fill = Color.New(0, 0, 1, 0.5)
circle.Props.Stroke = ColorAndDistance.New(Color.New(1, 0, 0), 5)

local layer2 = screen.Layer(2)
layer2.Rotation = -math.deg(math.sin(screen.TimeSinceStart()))
layer2.Origin = screen.Bounds() / 2
layer2.Text("Hello cruel world", screenDim / 2, font, goldenGlow)
local bezier = layer2.Bezier(Vec2.New(), Vec2.New(screenDim.x, screenDim.y / 3), screenDim)
bezier.Props.Stroke = ColorAndDistance.New(Color.New(1.5, 1.5, 1.5), 5)



screen.Animate(1)
