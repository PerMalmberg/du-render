local Stream = require("Stream")
local screen = library.getLinkByName("screen")
local time = system.getUtcTime

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
        stream.Write(wave[i])
        i = (i + 1) % (#wave + 1)
    end

    stream.Tick()
end

system:onEvent("onUpdate", onUpdate)
