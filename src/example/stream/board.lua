local Stream     = require("Stream")
local Vec2       = require("native/Vec2")
local screen     = library.getLinkByClass("ScreenUnit")
local time       = system.getUtcTime

local layout     = require("test_layouts/layout")
local layoutSent = false
local t          = time()

local function onData(data)
    system.print("From board: " .. data)
end

local function onTimeout(isTimedOut, stream)
    if isTimedOut then
        layoutSent = false
    elseif not layoutSent then
        stream.Write({ screen_layout = layout })
        stream.Write({ activate_page = "firstpage" })
        layoutSent = true
    end
end

local stream = Stream.New(screen, onData, 1, onTimeout)

local toggle = 1

local function onUpdate()
    local now = time()
    if now - t > 0.3 then
        t = now

        if toggle == 1 then
            toggle = 2
        else
            toggle = 1
        end

        local value = math.abs(math.sin(t / 10))
        if not stream.WaitingToSend() then
            stream.Write(
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
                    },
                    circle = {
                        style = {
                            hover = string.format("circle_style_hover_%d", toggle),
                        }
                    }
                })
        end
    end

    stream.Tick()
end

system:onEvent("onUpdate", onUpdate)
