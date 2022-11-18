local Color = require("native/Color")

---@class ColorAndDistance
---@field Color Color The color
---@field Distance number The distance
---@field Clone fun():ColorAndDistance

local ColorAndDistance = {}
ColorAndDistance.__index = ColorAndDistance

---Creates a new Shadow
---@param color Color
---@param distance number
function ColorAndDistance.New(color, distance)
    local s = {
        Color = color,
        Distance = distance
    }

    ---Clones the ColorAndDistance
    ---@return ColorAndDistance
    function s.Clone()
        return ColorAndDistance.New(s.Color.Clone(), s.Distance)
    end

    return setmetatable(s, ColorAndDistance)
end

return ColorAndDistance
