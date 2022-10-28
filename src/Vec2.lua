--- A 2 component vector based on cpml/Vec2
--- https://github.com/excessive/cpml/blob/master/modules/Vec2.lua

local atan2 = math.atan
local sqrt  = math.sqrt
local cos   = math.cos
local sin   = math.sin

---@class Vec2
---@field x number
---@field y number
---@field New fun(x:number|{x:number,y:number}|number[], y:number|nil):Vec2
---@field unit_x Vec2 X axis of rotation
---@field unit_y Vec2 Y axis of rotation
---@field zero Vec2 Empty vector
---@field FromCartesian fun(radius:number, theta:number):Vec2
---@field Clone fun(v:Vec2):Vec2
---@field Add fun(a:Vec2, b:Vec2):Vec2 Add two vectors.
---@field Sub fun(a:Vec2, b:Vec2):Vec2 Subtract two vectors.
---@field Mul fun(a:Vec2, b:Vec2):Vec2 Multiply two vectors.
---@field Div fun(a:Vec2, b:Vec2):Vec2 Divide two vectors.
---@field Normalize fun(a:Vec2):Vec2
---@field Trim fun(a:Vec2, len:number):Vec2
---@field Cross fun(a:Vec2, b:Vec2):number
---@field Dot fun(a:Vec2, b:Vec2):number
---@field Len fun(a:Vec2):number
---@field Len2 fun(a:Vec2):number
---@field Dist fun(a:Vec2, b:Vec2):number
---@field Dist2 fun(a:Vec2, b:Vec2):number
---@field Scale fun(a:Vec2, b:number):Vec2
---@field Rotate fun(a:Vec2, phi:number)
---@field Perpendicular fun(a:Vec2):Vec2
---@field AngleTo fun(a:Vec2, b:Vec2):number
---@field Lerp fun(a:Vec2, b:Vec2, s:number):Vec2
---@field Unpack fun(a:Vec2):number, number
---@field ComponentMin fun(a:Vec2, b:Vec2):Vec2
---@field ComponentMax fun(a:Vec2, b:Vec2):Vec2
---@field IsVec2 fun(a:Vec2):boolean
---@field IsZero fun(a:Vec2):boolean
---@field ToPolar fun(a:Vec2):number, number
---@field FlipX fun(a:Vec2):Vec2
---@field FlipY fun(a:Vec2):Vec2
---@field ToString fun(a:Vec2):string
---@operator add(Vec2):Vec2
---@operator sub(Vec2):Vec2
---@operator div(Vec2):Vec2
---@operator div(number):Vec2
---@operator mul(Vec2):Vec2
---@operator mul(number):Vec2
---@operator unm:Vec2

local Vec2 = {}
Vec2.__index = Vec2

---Create a new Vec2
---@param x number|{x:number,y:number}|number[]|nil
---@param y number|nil
---@return Vec2
function Vec2.New(x, y)
    local s = {}

    if x and y then
        s.x = x
        s.y = y
        -- {x, y} or {x=x, y=y}
    elseif type(x) == "table" then
        s.x, s.y = x.x or x[1], x.y or x[2]
    elseif type(x) == "number" then
        s.x = x
        s.y = x
    else
        s.x = 0
        s.y = 0
    end

    return setmetatable(s, Vec2)
end

Vec2.unit_x = Vec2.New(1, 0)
Vec2.unit_y = Vec2.New(0, 1)
Vec2.zero   = Vec2.New(0, 0)

---Convert point from polar to cartesian.
---@param radius number Radius of the point
---@param theta number Angle of the point (in radians)
---@return Vec2
function Vec2.FromCartesian(radius, theta)
    return Vec2.New(radius * cos(theta), radius * sin(theta))
end

---Clone a vector.
---@param a Vec2 Vector to be cloned
---@return Vec2
function Vec2.Clone(a)
    return Vec2.New(a.x, a.y)
end

---Add two vectors.
---@param a Vec2 Left hand operand
---@param b Vec2 Right hand operand
---@return Vec2 out
function Vec2.Add(a, b)
    return Vec2.New(
        a.x + b.x,
        a.y + b.y
    )
end

---Subtract one vector from another.
---Order: If a and b are positions, computes the direction and distance from b
---to a.
---@param a Vec2 Left hand operand
---@param b Vec2 Right hand operand
---@return Vec2 out
function Vec2.Sub(a, b)
    return Vec2.New(
        a.x - b.x,
        a.y - b.y
    )
end

--- Multiply a vector by another vector.
-- Component-size multiplication not matrix multiplication.
---@param a Vec2  Left hand operand
---@param b Vec2  Right hand operand
---@return Vec2 out
function Vec2.Mul(a, b)
    return Vec2.New(
        a.x * b.x,
        a.y * b.y
    )
end

--- Divide a vector by another vector.
-- Component-size inv multiplication. Like a non-uniform scale().
---@param a Vec2  Left hand operand
---@param b Vec2  Right hand operand
---@return Vec2 out
function Vec2.Div(a, b)
    return Vec2.New(
        a.x / b.x,
        a.y / b.y
    )
end

--- Get the normal of a vector.
---@param a Vec2  Vector to normalize
---@return Vec2 out
function Vec2.Normalize(a)
    if a:IsZero() then
        return Vec2.New()
    end
    return a:Scale(1 / a:Len())
end

--- Trim a vector to a given length.
---@param a Vec2  Vector to be trimmed
---@param len number Length to trim the vector to
---@return Vec2
function Vec2.Trim(a, len)
    return a:Normalize():Scale(math.min(a:Len(), len))
end

--- Get the cross product of two vectors.
-- Order: Positive if a is clockwise from b. Magnitude is the area spanned by
-- the parallelograms that a and b span.
---@param a Vec2  Left hand operand
---@param b Vec2  Right hand operand
---@return number
function Vec2.Cross(a, b)
    return a.x * b.y - a.y * b.x
end

--- Get the dot product of two vectors.
---@param a Vec2  Left hand operand
---@param b Vec2  Right hand operand
---@return number
function Vec2.Dot(a, b)
    return a.x * b.x + a.y * b.y
end

--- Get the length of a vector.
---@param a Vec2  Vector to get the length of
---@return number
function Vec2.Len(a)
    return sqrt(a.x * a.x + a.y * a.y)
end

--- Get the squared length of a vector.
---@param a Vec2  Vector to get the squared length of
---@return number
function Vec2.Len2(a)
    return a.x * a.x + a.y * a.y
end

--- Get the distance between two vectors.
---@param a Vec2  Left hand operand
---@param b Vec2  Right hand operand
---@return number
function Vec2.Dist(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return sqrt(dx * dx + dy * dy)
end

--- Get the squared distance between two vectors.
---@param a Vec2  Left hand operand
---@param b Vec2  Right hand operand
---@return number
function Vec2.Dist2(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return dx * dx + dy * dy
end

--- Scale a vector by a scalar.
---@param a Vec2  Left hand operand
---@param b number Right hand operand
---@return Vec2 out
function Vec2.Scale(a, b)
    return Vec2.New(
        a.x * b,
        a.y * b
    )
end

--- Rotate a vector.
---@param a Vec2  Vector to rotate
---@param phi number Angle to rotate vector by (in radians)
---@return Vec2 out
function Vec2.Rotate(a, phi)
    local c = cos(phi)
    local s = sin(phi)
    return Vec2.New(
        c * a.x - s * a.y,
        s * a.x + c * a.y
    )
end

--- Get the perpendicular vector of a vector.
---@param a Vec2  Vector to get perpendicular axes from
---@return Vec2 out
function Vec2.Perpendicular(a)
    return Vec2.New(-a.y, a.x)
end

--- Signed angle from one vector to another.
-- Rotations from +x to +y are positive.
---@param a Vec2  Vector
---@param b Vec2  Vector
---@return number angle in [-pi, pi]
function Vec2.AngleTo(a, b)
    if b then
        local angle = atan2(b.y, b.x) - atan2(a.y, a.x)
        -- convert to (-pi, pi]
        if angle > math.pi then
            angle = angle - 2 * math.pi
        elseif angle <= -math.pi then
            angle = angle + 2 * math.pi
        end
        return angle
    end

    return atan2(a.y, a.x)
end

--- Lerp between two vectors.
---@param a Vec2  Left hand operand
---@param b Vec2  Right hand operand
---@param s number Step value
---@return Vec2
function Vec2.Lerp(a, b, s)
    return a + (b - a) * s
end

--- Unpack a vector into individual components.
---@param a Vec2  Vector to unpack
---@return number x
---@return number y
function Vec2.Unpack(a)
    return a.x, a.y
end

--- Return the component-wise minimum of two vectors.
---@param a Vec2  Left hand operand
---@param b Vec2  Right hand operand
---@return Vec2 A vector where each component is the lesser value for that component between the two given vectors.
function Vec2.ComponentMin(a, b)
    return Vec2.New(math.min(a.x, b.x), math.min(a.y, b.y))
end

--- Return the component-wise maximum of two vectors.
---@param a Vec2  Left hand operand
---@param b Vec2  Right hand operand
---@return Vec2 A vector where each component is the lesser value for that component between the two given vectors.
function Vec2.ComponentMax(a, b)
    return Vec2.New(math.max(a.x, b.x), math.max(a.y, b.y))
end

--- Return a boolean showing if a table is or is not a Vec2.
---@param a any  Vector to be tested
---@return boolean is_Vec2
function Vec2.IsVec2(a)
    return type(a) == "table" and
        type(a.x) == "number" and
        type(a.y) == "number"
end

--- Return a boolean showing if a table is or is not a zero Vec2.
---@param a Vec2  Vector to be tested
---@return boolean is_zero
function Vec2.IsZero(a)
    return a.x == 0 and a.y == 0
end

--- Convert point from cartesian to polar.
---@param a Vec2  Vector to convert
---@return number radius
---@return number theta
function Vec2.ToPolar(a)
    local radius = sqrt(a.x ^ 2 + a.y ^ 2)
    local theta  = atan2(a.y, a.x)
    theta        = theta > 0 and theta or theta + 2 * math.pi
    return radius, theta
end

-- Negate x axis only of vector.
---@param a Vec2  Vector to x-flip.
---@return Vec2 x-flipped vector
function Vec2.FlipX(a)
    return Vec2.Vec2.New(-a.x, a.y)
end

-- Negate y axis only of vector.
---@param a Vec2  Vector to y-flip.
---@return Vec2 y-flipped vector
function Vec2.FlipY(a)
    return Vec2.Vec2.New(a.x, -a.y)
end

--- Return a formatted string.
---@param a Vec2  Vector to be turned into a string
---@return string formatted
function Vec2.ToString(a)
    return string.format("(%+0.3f,%+0.3f)", a.x, a.y)
end

---Negation operator
---@param a Vec2
---@return Vec2
function Vec2.__unm(a)
    return Vec2.New(-a.x, -a.y)
end

---Equality operator
---@param a Vec2|any
---@param b Vec2|any
---@return boolean
function Vec2.__eq(a, b)
    if not Vec2.IsVec2(a) or not Vec2.IsVec2(b) then
        return false
    end
    return a.x == b.x and a.y == b.y
end

---Addition operator
---@param a Vec2
---@param b Vec2
---@return Vec2
function Vec2.__add(a, b)
    return a:Add(b)
end

---Subtraction operator
---@param a Vec2
---@param b Vec2
---@return Vec2
function Vec2.__sub(a, b)
    return a:Sub(b)
end

---Multiplication operator
---@param a Vec2
---@param b Vec2|number
---@return Vec2
function Vec2.__mul(a, b)
    if Vec2.IsVec2(b) then
        ---@cast b Vec2
        return a:Mul(b)
    end

    ---@cast b number
    return a:Scale(b)
end

---Division operator
---@param a Vec2
---@param b Vec2|number
---@return Vec2
function Vec2.__div(a, b)
    if Vec2.IsVec2(b) then
        ---@cast b Vec2
        return a:Div(b)
    end

    return a:Scale(1 / b)
end

return Vec2
