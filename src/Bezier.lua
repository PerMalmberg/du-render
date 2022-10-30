local rs = require("RenderScript").Instance()

---@class Bezier
---@field PosA Vec2
---@field PosB Vec2
---@field PosC Vec2
---@field Props Props
---@field Render fun()

local Bezier = {}
Bezier.__index = Bezier

---Creates a new Bezier
---@param layer Layer
---@param a Vec2
---@param b Vec2
---@param c Vec2
---@param props Props
function Bezier.New(layer, a, b, c, props)
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
        rs.AddBezier(layerId, x1, y1, x2, y2, x3, y3)
    end

    return setmetatable(s, Bezier)
end

return Bezier
