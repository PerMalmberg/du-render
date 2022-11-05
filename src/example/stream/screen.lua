local Font   = require("Font")
local Color  = require("Color")
local Screen = require("Screen")
local Stream = require("Stream")
local Vec2   = require("Vec2")
local Binder = require("Binder")
local json   = require("dkjson")

local screen = Screen.New()
local layer = screen.Layer(1)
local font = Font.Get(FontName.Play, 30)

layer.Text(string.format("%0.2f%%", screen.Stats()), Vec2.New(), font)

local middle = screen.Bounds() / 2
local t = layer.Text("", middle, font)
t.Props.Fill = Color.New(0, 2, 0)

local binder = Binder.New()
local path = binder.Path("")
path.Text(t, "Text", "man")
path.Color(t.Props, "Fill", "color")
path.Vec2(t, "Pos", "pos")


local onDataReceived = function(data)
    local j = json.decode(data)
    if j then
        binder.MergeData(j)
    end
end

local timeoutCallback = function(isTimedOut)

end

local stream = Stream.New(_ENV, onDataReceived, 1, timeoutCallback)

stream.Tick()

binder.Render()
screen.Render()
