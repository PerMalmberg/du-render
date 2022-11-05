local Stream = require("Stream")
local screen = library.getLinkByName("screen")
local time = system.getUtcTime
local json = require("dkjson")
local Vec2 = require("Vec2")
local Color = require("Color")

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
            { man = wave[i],
                color = Color.New(1, 1, 0, 1):ToString(),
                pos = Vec2.New(100, 150):ToString()
            }))
        i = 1 + (i % #wave)
    end

    stream.Tick()
end

system:onEvent("onUpdate", onUpdate)
