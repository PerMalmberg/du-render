local Stream = require("Stream")
local Vec2   = require("native/Vec2")
local screen = library.getLinkByClass("ScreenUnit")
local time   = system.getUtcTime
local json   = require("dkjson")

local layoutString = library.embedFile("../../test_layouts/layout_min.json")
local layout       = json.decode(layoutString)
local layoutSent   = false
local t            = time()

local function onData(data)
    system.print("From board: " .. data)
end

local function onTimeout(isTimedOut, stream)
    if isTimedOut then
        layoutSent = false
    elseif not layoutSent then
        stream.Write(json.encode({ screen_layout = layout }))
        stream.Write(json.encode({ activate_page = "firstpage" }))
        layoutSent = true
    end
end

local stream = Stream.New(screen, onData, 1, onTimeout)

local function onUpdate()
    local now = time()
    if now - t > 0.3 then
        t = now
        local value = math.abs(math.sin(t / 10))
        if not stream.WaitingToSend() then
            stream.Write(json.encode(
                {
                    gauge = {
                        fuel = {
                            value = Vec2.New(1, value):ToString(),
                            value100 = value * 100
                        }
                    },
                    path = {
                        to = {
                            data = {
                                key = "from board"
                            }
                        }
                    }
                }))
        end
    end

    stream.Tick()
end

system:onEvent("onUpdate", onUpdate)
