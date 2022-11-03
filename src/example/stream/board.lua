local Stream = require("Stream")
local screen = library.getLinkByName("screen")
local time = system.getUtcTime

local wave = { "~o~", "\\o\\", "|o|", "/o/" }
local i = 1
local t = time()

local function onData(data)
    i = i + 1
    if i > #wave then
        i = 1
    end
end

local stream = Stream.New(screen, 30, onData)

local function onUpdate()
    local now = time()
    if now - t > 0.1 then
        t = now
        stream.Write(wave[i])
    end

    stream.OnUpdate(1)
end

system:onEvent("onUpdate", onUpdate)
