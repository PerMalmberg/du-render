local rs = require("RenderScript").Instance()
local Vec2 = require("Vec2")
local Layer = require("Layer")

---@class Screen Represents a screen
---@field New fun():Screen
---@field Layer fun():Layer
---@field Render fun(frames:integer)
---@field Stats fun():number
---@field CursorPos fun():Vec2
---@field Pressed fun():boolean
---@field Released fun():boolean
---@field DetermineHitElement fun():table

local Screen = {}
Screen.__index = Screen

function Screen.New()
    local s = {}
    local layers = {} ---@type Layer[]

    ---Gets the layer with the given id
    ---@param id integer
    ---@return Layer
    function s.Layer(id)
        while id > #layers do
            table.insert(layers, Layer.New(s))
        end

        return layers[id]
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

    ---Gets the cursor position
    ---@return Vec2
    function s.CursorPos()
        return Vec2.New(rs.GetCursor())
    end

    ---Returns true if the cursor was pressed since the last frame.
    ---@return boolean
    function s.Pressed()
        return rs.GetCursorPressed()
    end

    ---Returns true if the cursor was released since the last frame.
    ---@return boolean
    function s.Released()
        return rs.GetCursorReleased()
    end

    ---Determines which element that is hit
    function s.DetermineHitElement()
        local cursor = Vec2.New(rs.GetCursor())

        for _, layer in ipairs(layers) do
            -- Here we can add check on layer clipping
            local hit = layer.DetermineHitElement(cursor)
            if hit then
                return hit
            end
        end

        return nil
    end

    return setmetatable(s, Screen)
end

return Screen
