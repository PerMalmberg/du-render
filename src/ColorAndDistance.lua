local Color = require("Color")

---@class ColorAndDistance
---@field Color Color The color
---@field Distance number The distance

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

    return setmetatable(s, ColorAndDistance)
end

return ColorAndDistance
