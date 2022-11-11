local Color = require("Color")
local rs = require("RenderScript").Instance()

-- https://github.com/hsluv/hsluv-lua
-- https://www.alanzucconi.com/2016/01/06/colour-interpolation/

---@class Gradient

local Gradient = {}
Gradient.__index = {}

---Creates a gradient
---@param layer Layer
---@param startColor Color
---@param endColor Color
---@param startCorner Vec2
---@param endCorner Vec2
---@return Gradient
function Gradient.New(layer, startColor, endColor, startCorner, endCorner)
    local s = {}

    ---Sets the colors
    ---@param startCol Color
    ---@param endCol Color
    function SetColors(startCol, endCol)
        startColor = startCol
        endColor = endCol
    end

    function s.Render()
        local diff = endCorner - startCorner
        local step = diff.y > 0 and 1 or -1
        local abs = diff:Abs()
        local steps = abs.y - 1
        local width = abs.x

        if steps <= 0 or width <= 0 then return end

        local count = 1
        local layerId = layer.Id
        for y = startCorner.y, endCorner.y, step do
            local c = startColor.LerpTo(endColor, count / steps)
            rs.SetNextStrokeWidth(layerId, 1)
            rs.SetNextStrokeColor(layerId, c:Unpack())
            rs.AddLine(layerId, startCorner.x, y, endCorner.x, y)
            count = count + 1
        end
    end

    return setmetatable(s, Gradient)
end

return Gradient
