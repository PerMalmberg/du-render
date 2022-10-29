local RS = require("RenderScript").Instance()
local Props = require("Props")
local Color = require("Color")
local TextAlign = require("TextAlign")
local Font = require("Font")
local Screen = require("Screen")

local screen = Screen.Instance()

-- Gets screen resolution
local w, h = RS.GetResolution()

local props = Props.New()
props.Fill = Color.New(2, 1, 0)
props.Align = TextAlign.New(RSAlignHor.Center, RSAlignVer.Middle)

local font = Font.Get(FontName.Montserrat, h * 0.05)

local hello = screen.Layer(1).Text("Hello cruel world", w / 2, h / 2, font, props)
screen.Layer(1).Text(string.format("%d/%d", RS.GetRenderCost(), RS.GetRenderCostMax()), w / 2,
    h / 2 + hello.Height(), font, props)

screen.Render(1)
