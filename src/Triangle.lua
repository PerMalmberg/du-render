local rs = require("RenderScript").Instance()

---@class Triangle
---@field PosA Vec2
---@field PosB Vec2
---@field PosC Vec2
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
        PosA = a,
        PosB = b,
        PosC = c,
        Props = props
    }

    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        local x1, y1 = s.PosA:Unpack()
        local x2, y2 = s.PosB:Unpack()
        local x3, y3 = s.PosC:Unpack()
        rs.AddTriangle(layerId, x1, y1, x2, y2, x3, y3)
    end

    --Determines if the position is within the element
    ---@param point Vec2
    ---@return boolean
    function s.Hit(point)
        -- https://www.youtube.com/watch?v=HYAgJN3x4GA
        local s1 = s.PosC.y - s.PosA.y;
        local s2 = s.PosC.x - s.PosA.x;
        local s3 = s.PosB.y - s.PosA.y;
        local s4 = point.y - s.PosA.y;

        local w1 = (s.PosA.x * s1 + s4 * s2 - point.x * s1) / (s3 * s2 - (s.PosB.x - s.PosA.x) * s1);
        local w2 = (s4 - w1 * s3) / s1;
        return w1 >= 0 and w2 >= 0 and (w1 + w2) <= 1;
    end

    return setmetatable(s, Triangle)
end

return Triangle
