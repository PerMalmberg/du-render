local Font      = require("Font")
local Color     = require("Color")
local Screen    = require("Screen")
local Stream    = require("Stream")
local Vec2      = require("Vec2")
local Binder    = require("Binder")
local Behaviour = require("Behaviour")
local json      = require("dkjson")

local screen = Screen.New()
local layer = screen.Layer(1)
local behavior = Behaviour.New()
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

local triangle = layer.Triangle(Vec2.New(150, 150), Vec2.New(150, 250), Vec2.New(250, 200))
triangle.Props.Fill = Color.New(0, 0, 1, 1)
behavior.OnMouseInsideOrOutside(triangle, function(element, event)
    if event == MouseState.MouseInside then
        element.Props.Rotation = 45
    else
        element.Props.Rotation = 0
    end
end)

behavior.OnMouseDownOrUp(triangle, function(element, event)
    if event == MouseState.MouseDown then
        element.Props.Fill = Color.New(1, 1, 1, 1)
    else
        --element.Props.Fill = Color.New(0, 1, 0, 1)
    end
end)

behavior.OnMouseClick(triangle, function(element, event)
    if event == MouseState.Click then
        logMessage("Click!")
    end
end)

local layer2 = screen.Layer(2)
local circle = layer2.Circle(Vec2.New(), 5)
circle.Pos = screen.CursorPos()

if triangle.Hit(screen.CursorPos()) then
    circle.Props.Fill = Color.New(0, 2, 0, 1)
else
    circle.Props.Fill = Color.New(1, 0, 0, 1)
end

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

behavior.TriggerEvents(screen)
binder.Render()
screen.Render(true)
