local rs = require("RenderScript").Instance()

---@class Triangle
---@field PosA Vec2
---@field PosB Vec2
---@field PosC Vec2
---@field Props Props
---@field Render fun()

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

    return setmetatable(s, Triangle)
end

return Triangle
