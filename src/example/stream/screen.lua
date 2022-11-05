local Font   = require("Font")
local Color  = require("Color")
local Screen = require("Screen")
local Stream = require("Stream")
local Vec2   = require("Vec2")

local screen = Screen.New()
local layer = screen.Layer(1)
local font = Font.Get(FontName.Play, 30)

local middle = screen.Bounds() / 2
local t = layer.Text(_ENV.wavingMan or "", middle, font)
t.Props.Fill = Color.New(0, 2, 0)

layer.Text(string.format("%0.2f%%", screen.Stats()), Vec2.New(), font)



local onDataReceived = function(data)
    _ENV.wavingMan = data
end

local timeoutCallback = function(isTimedOut)

end

local stream = Stream.New(_ENV, onDataReceived, 1, timeoutCallback)

stream.Tick()

screen.Render()
