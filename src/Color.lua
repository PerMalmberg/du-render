local max = math.max
local min = math.min

local clamp = function(v, lower, upper)
    return min(max(v, lower), upper)
end
---@class Color
---@field ToString fun():string
---@field Unpack fun():number, number, number, number Unpacks the color into its components
---@field Red number
---@field Green number
---@field Blue number
---@field Alpha number

local Color = {}
Color.__index = Color


---Create a new color. Numbers above 1 results in HDR rendering
---@param red number
---@param green number
---@param blue number
---@param alpha number|nil
function Color.New(red, green, blue, alpha)
    local s = {
        Red = clamp(red, 0, 5),
        Green = clamp(green, 0, 5),
        Blue = clamp(blue, 0, 5),
        Alpha = clamp(alpha or 1, 0, 1)
    }

    ---Prints the color
    ---@return string
    function Color.ToString()
        return string.format("r: %0.3f, g: %0.3f, b: %0.3f, a: %0.3f", s.Red, s.Green, s.Blue, s.Alpha)
    end

    ---ToString meta function
    ---@return string
    function Color.__tostring()
        return s.ToString()
    end

    ---Unpacks the color
    ---@return number, number, number, number
    function s.Unpack(c)
        return c.Red, c.Green, c.Blue, c.Alpha
    end

    return setmetatable(s, Color)
end

---Creates a transparent color
---@return Color
function Color.Transparent()
    return Color.New(0, 0, 0, 0)
end

return Color
