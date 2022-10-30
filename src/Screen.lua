local rs = require("RenderScript").Instance()
local Vec2 = require("Vec2")
local Layer = require("Layer")

---@class Screen
---@field Instance fun():Screen
---@field Layer fun():Layer
---@field Add fun(c:table)
---@field Render fun(frames:integer)
---@field Stats fun():number

local Screen = {}
Screen.__index = Screen

local singelton

function Screen.Instance()
    if singelton then
        return singelton
    end

    local s = {}
    local layers = {} ---@type Layer[]
    local components = {} ---@type table[]

    ---Gets the layer with the given id
    ---@param id integer
    ---@return Layer
    function s.Layer(id)
        while id > #layers do
            table.insert(layers, Layer.New(s))
        end

        return layers[id]
    end

    function s.Add(comp)
        table.insert(components, comp)
    end

    ---Returns the width and height, in pixels the text occupies.
    ---@return Vec2
    function s.Bounds()
        return Vec2.New(rs.GetResolution())
    end

    ---Width of screen
    ---@return number
    function s.Width()
        return s.Bounds().x
    end

    ---Height of screen
    ---@return number
    function s.Height()
        return s.Bounds().y
    end

    ---Renders the screen content
    function s.Render()
        for i = 1, #layers do
            layers[i].Render()
        end

        for i = 1, #components do
            components[i].Render()
        end
    end

    ---Renders and animates the screen context
    ---@param frames integer
    function s.Animate(frames)
        s.Render()
        rs.RequestAnimationFrame(frames)
    end

    ---Gets the render cost in percentage
    ---@return number
    function s.Stats()
        return rs.GetRenderCost() / rs.GetRenderCostMax() * 100
    end

    ---Gets the number of seconds since the screen started
    ---@return number
    function s.TimeSinceStart()
        return rs.GetTime()
    end

    ---Gets the number of seconds between each frame
    ---@return number
    function s.DeltaTime()
        return rs.GetDeltaTime()
    end

    singelton = setmetatable(s, Screen)
    return singelton
end

return Screen
