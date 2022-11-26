local Binder = require("Binder")
local Font   = require("native/Font")
local Props  = require("native/Props")
local Color  = require("native/Color")
local rs     = require("native/RenderScript").Instance()

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
    local binder   = Binder.New()
    local behavior = require("Behaviour").New()
    local json     = require("dkjson")
    local loader ---@type Layout

    local onDataReceived = function(data)
        local j = json.decode(data)
        if j then
            local screen_layout = Binder.GetTblByPath(j, "screen_layout")
            local activate_page = Binder.GetStrByPath(j, "activate_page")

            if screen_layout then
                if not loader.SetLayout(screen_layout) then
                    logMessage("Could not load layout")
                end
            elseif activate_page then
                loader.Activate(activate_page)
            else
                binder.MergeData(j)
            end
        end
    end

    local timeoutCallback = function(isTimedOut, stream)
        if isTimedOut then
            logMessage("Timout!")
            screen.Clear()
            binder.Clear()
            behavior.Clear()
            local l = screen.Layer(1)
            local msg = "No communication!"
            local font = Font.Get(FontName.Play, 30)
            local text = l.Text(msg, screen.Bounds() / 2 - (rs.GetTextBounds(font, msg) / 2), font, Props.New())
            text.Props.Fill = Color.New(1, 0, 0)
        end
    end

    local stream = require("Stream").New(_ENV, onDataReceived, 1, timeoutCallback)
    loader = require("Layout").New(screen, behavior, binder, stream)

    ---Call this this to setup a slower update than Animate()
    ---@param frames integer
    ---@param displayStats boolean
    function s.Render(frames, displayStats)
        stream.Tick()
        binder.Render()
        behavior.TriggerEvents(screen)
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
