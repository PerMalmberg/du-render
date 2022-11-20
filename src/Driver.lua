---@class Driver
---@field Tick fun()
---@field Render fun(frames:integer, displayStats:boolean)
---@field Animate fun(displayStats?:boolean)

local Driver = {}
Driver.__index = Driver

function Driver.Instance()
    if _ENV.DriverSingelton then
        return _ENV.DriverSingelton
    end

    local s = {}

    local screen   = require("native/Screen").New()
    local binder   = require("Binder").New()
    local behavior = require("Behaviour").New()
    local json     = require("dkjson")
    local loader ---@type ComponentLoader

    local onDataReceived = function(data)
        local j = json.decode(data)
        if j then
            if j.screen_layout then
                if not loader.Load(j.screen_layout) then
                    logMessage("Could not load layout")
                end
            else
                binder.MergeData(j)
            end
        end
    end

    local timeoutCallback = function(isTimedOut, stream)

    end

    local stream = require("Stream").New(_ENV, onDataReceived, 1, timeoutCallback)
    loader = require("ComponentLoader").New(screen, behavior, binder, stream)

    ---Call this each frame
    function s.Tick()
        stream.Tick()
        binder.Render()
        behavior.TriggerEvents(screen)
    end

    ---Call this this to setup next frame
    ---@param frames integer
    ---@param displayStats boolean
    function s.Render(frames, displayStats)
        screen.Animate(frames, displayStats)
    end

    ---Call this to enable animation
    ---@param displayStats? boolean
    function s.Animate(displayStats)
        s.Render(1, displayStats or false)
    end

    _ENV.DriverSingelton = setmetatable(s, Driver)
    return s
end

return Driver
