local rs = require("native/RenderScript").Instance()

---@class Triangle
---@field Pos1 Vec2
---@field Pos2 Vec2
---@field Pos3 Vec2
---@field Visible boolean
---@field Hitable boolean
---@field Props Props
---@field Render fun()
---@field Hit fun(point:Vec2):boolean

local Triangle = {}
Triangle.__index = Triangle

---Creates a new Triangle
---@param layer Layer
---@param a Vec2
---@param b Vec2
---@param c Vec2
---@param props Props
function Triangle.New(layer, a, b, c, props)
    local s = {
        Layer = layer,
        Pos1 = a,
        Pos2 = b,
        Pos3 = c,
        Props = props,
        Visible = true,
        Hitable = true
    }

    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        local x1, y1 = s.Pos1:Unpack()
        local x2, y2 = s.Pos2:Unpack()
        local x3, y3 = s.Pos3:Unpack()
        rs.AddTriangle(layerId, x1, y1, x2, y2, x3, y3)
    end

    --Determines if the position is within the element
    ---@param point Vec2
    ---@return boolean
    function s.Hit(point)
        -- https://www.youtube.com/watch?v=HYAgJN3x4GA
        local s1 = s.Pos3.y - s.Pos1.y;
        local s2 = s.Pos3.x - s.Pos1.x;
        local s3 = s.Pos2.y - s.Pos1.y;
        local s4 = point.y - s.Pos1.y;

        local w1 = (s.Pos1.x * s1 + s4 * s2 - point.x * s1) / (s3 * s2 - (s.Pos2.x - s.Pos1.x) * s1);
        local w2 = (s4 - w1 * s3) / s1;
        return s.Hitable and s.Visible and w1 >= 0 and w2 >= 0 and (w1 + w2) <= 1;
    end

    return setmetatable(s, Triangle)
end

return Triangle
