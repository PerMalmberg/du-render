local max = math.max
local min = math.min

local clamp = function(v, lower, upper)
    return min(max(v, lower), upper)
end
---@class Color
---@field ToString fun():string
---@field FromString fun(s:string|nil):Color
---@field Unpack fun():number, number, number, number Unpacks the color into its components
---@field Red number
---@field Green number
---@field Blue number
---@field Alpha number
---@field Clone fun():Color

local Color = {}
Color.__index = Color


---Create a new color. Numbers above 1 results in HDR rendering
---@param red number
---@param green number
---@param blue number
---@param alpha? number
function Color.New(red, green, blue, alpha)
    local s = {
        Red = clamp(red, 0, 5),
        Green = clamp(green, 0, 5),
        Blue = clamp(blue, 0, 5),
        Alpha = clamp(alpha or 1, 0, 1)
    }

    ---Prints the color
    ---@return string
    function s.ToString()
        return string.format(Color.FormatString, s.Red, s.Green, s.Blue, s.Alpha)
    end

    return setmetatable(s, Color)
end

---Unpacks the color
---@return number, number, number, number
function Color.Unpack(c)
    return c.Red, c.Green, c.Blue, c.Alpha
end

---Clones the color
---@param c Color
---@return Color
function Color.Clone(c)
    return Color.New(c.Red, c.Green, c.Blue, c.Alpha)
end

---ToString meta function
---@param c Color
---@return string
function Color.__tostring(c)
    return c.ToString()
end

---@param a Color
---@param b Color
---@return boolean
function Color.__eq(a, b)
    return a.Red == b.Red
        and a.Green == b.Green
        and a.Blue == b.Blue
        and a.Alpha == b.Alpha
end

---Creates a transparent color
---@return Color
function Color.Transparent()
    return Color.New(0, 0, 0, 0)
end

---Creates a Color from a string
---@param s string|nil
---@return Color
function Color.FromString(s)
    if not s then return Color.Transparent() end

    local r, g, b, a = s:match("^r(%d*%.?%d+),g(%d*%.?%d+),b(%d*%.?%d+),a(%d*%.?%d+)$")
    r = tonumber(r)
    g = tonumber(g)
    b = tonumber(b)
    a = tonumber(a)
    if r and g and b and a then
        return Color.New(r, g, b, a)
    end

    return Color.Transparent()
end

Color.FormatString = "r%0.3f,g%0.3f,b%0.3f,a%0.3f"

return Color
