local Stream = require("Stream")
local screen = library.getLinkByClass("ScreenUnit")
local time = system.getUtcTime
local json = require("dkjson")
local Vec2 = require("native/Vec2")
local Color = require("native/Color")

local wave = { "~o~", "\\o\\", "|o|", "/o/" }
local i = 1
local t = time()

local function onData(data)
end

local function onTimeout(isTimedOut)

end

local stream = Stream.New(screen, onData, 1, onTimeout)

local function onUpdate()
    local now = time()
    if now - t > 0.3 then
        t = now
        stream.Write(json.encode(
            { path = { to = { data = { key = "from board" } } } }))
    end

    stream.Tick()
end

system:onEvent("onUpdate", onUpdate)
