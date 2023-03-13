local Binder   = require("Binder")
local Font     = require("native/Font")
local Props    = require("native/Props")
local Color    = require("native/Color")
local Stream   = require("Stream")
local Layout   = require("Layout")
local rs       = require("native/RenderScript").Instance()

---@class Driver
---@field Tick fun()
---@field Render fun(frames:integer, displayStats:boolean)
---@field Animate fun(displayStats?:boolean)
---@field SetOfflineLayout fun(layout:table|nil)

local Driver   = {}
Driver.__index = Driver

function Driver.Instance()
    if _ENV.DriverSingelton then
        return _ENV.DriverSingelton
    end

    local s               = {}
    local offlineLayout   = nil ---@type table|nil

    local screen          = require("native/Screen").New()
    local binder          = Binder.New()
    local behavior        = require("Behaviour").New()
    local loader ---@type Layout

    local onDataReceived  = function(data)
        local screen_layout = Binder.GetTblByPath(data, "screen_layout")
        local activate_page = Binder.GetStrByPath(data, "activate_page")

        if screen_layout then
            if not loader.SetLayout(screen_layout) then
                rs.Log("Could not load layout")
            end
        elseif activate_page then
            loader.Activate(activate_page)
        else
            binder.MergeData(data)
        end
    end

    local timeoutCallback = function(isTimedOut, stream)
        if isTimedOut then
            screen.Clear()
            binder.Clear()
            behavior.Clear()

            if offlineLayout == nil then
                local l = screen.Layer(1)
                local msg = "No communication!"
                local font = Font.Get(FontName.Play, 30)
                local text = l.Text(msg, screen.Bounds() / 2 - (rs.GetTextBounds(font, msg) / 2), font, Props.New())
                text.Props.Fill = Color.New(1, 0, 0)
            elseif not (loader.SetLayout(offlineLayout) and loader.Activate("offline")) then
                rs.Log("Could not load offline layout or activate the page")
            end
        end
    end

    local stream          = Stream.New(_ENV, onDataReceived, 1, timeoutCallback)
    loader                = Layout.New(screen, behavior, binder, stream)

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

    ---Sets the layout to use when there is no communication
    ---@param layout table The layout, as Lua table
    function s.SetOfflineLayout(layout)
        offlineLayout = layout
    end

    _ENV.DriverSingelton = setmetatable(s, Driver)
    return s
end

return Driver
