local rs = require("RenderScript").Instance()

---@class Circle
---@field Pos Vec2
---@field Radius number
---@field Props Props
---@field Render fun()
---@field Hit fun(point:Vec2):boolean

local Circle = {}
Circle.__index = Circle

---Creates a new Circle
---@param layer Layer
---@param pos Vec2
---@param radius number
---@param props Props
function Circle.New(layer, pos, radius, props)
    local s = {
        Layer = layer,
        Pos = pos,
        Radius = radius,
        Props = props
    }

    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        local x, y = s.Pos:Unpack()
        rs.AddCircle(layerId, x, y, s.Radius)
    end

    ---Determines if the position is within the element
    ---@param point Vec2
    ---@return boolean
    function s.Hit(point)
        return (pos - point):Len() <= s.Radius
    end

    return setmetatable(s, Circle)
end

return Circle
