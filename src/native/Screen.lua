local rs = require("native/RenderScript").Instance()
local Vec2 = require("native/Vec2")
local Layer = require("native/Layer")
local Font = require("native/Font")

---@class Screen Represents a screen
---@field New fun():Screen
---@field Layer fun(id:integer):Layer
---@field Render fun(printStats:boolean)
---@field Animate fun(frames:integer, printStats:boolean)
---@field Bounds fun():Vec2
---@field Stats fun():number
---@field CursorPos fun():Vec2
---@field Pressed fun():boolean
---@field Released fun():boolean
---@field DetermineHitElement fun():table
---@field Clear fun()
---@field CountParts fun(onlyVisible:boolean?):integer, integer
---@field TimeSinceStart fun():number

local Screen = {}
Screen.__index = Screen

---Creates a new Screen
---@return Screen
function Screen.New()
    local s = {}
    local layers = {} ---@type Layer[]

    ---Gets the layer with the given id
    ---@param id integer
    ---@return Layer
    function s.Layer(id)
        while id > #layers do
            table.insert(layers, Layer.New())
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
    ---@param printStats boolean
    function s.Render(printStats)
        for i = 1, #layers do
            layers[i].Render()
        end

        if printStats then
            local layer
            -- Render on top-most layer
            if #layers == 0 then
                layer = s.Layer(1)
                -- New layer so need to render it to get its id.
                layer.Render()
            else
                layer = layers[#layers]
            end

            local costFont = Font.Get(FontName.Play, 20)
            local cost = string.format("Res: %s, cost: %0.2f%%", s.Bounds():ToString(), s.Stats())
            local textBounds = rs.GetTextBounds(costFont, cost)
            local rWidth = rs.GetTextBounds(costFont, "R").x
            local pos = Vec2.New(rWidth, s.Bounds().y - textBounds.y)
            rs.SetNextFillColor(layer.Id, 1, 1, 1, 1)
            rs.AddText(layer.Id, costFont.GetID(), cost, pos:Unpack())
        end

        Font.Clear()
    end

    function s.Clear()
        for i = 1, #layers do
            layers[i].Clear()
        end
    end

    ---Renders and animates the screen context
    ---@param frames integer
    ---@param printCost boolean
    function s.Animate(frames, printCost)
        s.Render(printCost)
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

        -- Top layer first
        for i = #layers, 1, -1 do
            -- Here we can add check on layer clipping
            local hit = layers[i].DetermineHitElement(cursor)
            if hit then
                return hit
            end
        end

        return nil
    end

    function s.CountParts(onlyVisible)
        if onlyVisible == nil then
            onlyVisible = false
        end

        local comps = 0
        for _, layer in ipairs(layers) do
            if onlyVisible then
                for _, comp in ipairs(layer.Components) do
                    if comp.Visible then
                        comps = comps + 1
                    end
                end
            else
                comps = comps + #layer.Components
            end
        end

        return #layers, comps
    end

    return setmetatable(s, Screen)
end

return Screen
