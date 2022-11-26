local Stream = require("Stream")
local screen = library.getLinkByClass("ScreenUnit")
local time = system.getUtcTime
local json = require("dkjson")

local layoutString = library.embedFile("../../test_layouts/layout_min.json")
local layout       = json.decode(layoutString)
local layoutSent   = false
local t            = time()
local t2           = t

local function onData(data)
    system.print("From board: " .. data)
end

local function onTimeout(isTimedOut, stream)
    if isTimedOut then
        layoutSent = false
    elseif not layoutSent then
        stream.Write(json.encode({ screen_layout = layout }))
        layoutSent = true
    end
end

local stream = Stream.New(screen, onData, 1, onTimeout)

local function onUpdate()
    local now = time()
    if now - t > 0.3 then
        t = now
        stream.Write(json.encode(
            { path = { to = { data = { key = "from board" } } } }))
    elseif now - t2 > 1 then
        stream.Write(json.encode({ activate_page = "firstpage" }))
        t2 = now
    end

    stream.Tick()
end

system:onEvent("onUpdate", onUpdate)
