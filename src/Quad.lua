local rs = require("RenderScript").Instance()

---@class Quad
---@field PosA Vec2
---@field PosB Vec2
---@field PosC Vec2
---@field PosD Vec2
---@field Props Props
---@field Render fun()

local Quad = {}
Quad.__index = Quad

---Creates a new Quad
---@param layer Layer
---@param a Vec2
---@param b Vec2
---@param c Vec2
---@param d Vec2
---@param props Props
function Quad.New(layer, a, b, c, d, props)
    local s = {
        Layer = layer,
        PosA = a,
        PosB = b,
        PosC = c,
        PosD = d,
        Props = props
    }

    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        local x1, y1 = s.PosA:Unpack()
        local x2, y2 = s.PosB:Unpack()
        local x3, y3 = s.PosC:Unpack()
        local x4, y4 = s.PosD:Unpack()
        rs.AddQuad(layerId, x1, y1, x2, y2, x3, y3, x4, y4)
    end

    return setmetatable(s, Quad)
end

return Quad
