local Stream       = require("Stream")
local ScreenDevice = require("device/ScreenDevice")
local Vec2         = require("native/Vec2")
local screen       = library.getLinkByClass("ScreenUnit")
local time         = system.getUtcTime

local layout       = require("test_layouts/layout")
local layoutSent   = false
local t            = time()

local BoardSide    = {}
BoardSide.__index  = BoardSide

function BoardSide.New()
    local s = {
        stream = nil ---@type Stream
    }

    function s.OnData(data)
        if type(data) == "table" then
            for k, v in pairs(data) do
                system.print("From screen: " .. data)
            end
        elseif type(data) == "string" then
            system.print(data)
        end
    end

    function s.OnTimeout(isTimedOut, stream)
        if isTimedOut then
            layoutSent = false
        elseif not layoutSent then
            s.stream.Write({ screen_layout = layout })
            s.stream.Write({ activate_page = "firstpage" })
            layoutSent = true
        end
    end

    function s.RegisterStream(stream)
        s.stream = stream
    end

    return setmetatable(s, BoardSide)
end

local stream = Stream.New(ScreenDevice.New(screen), BoardSide.New(), 1)

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
