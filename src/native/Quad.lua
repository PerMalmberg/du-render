local rs = require("native/RenderScript").Instance()

---@class Quad
---@field Pos1 Vec2
---@field Pos2 Vec2
---@field Pos3 Vec2
---@field PosD Vec2
---@field Visible boolean
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
        Pos1 = a,
        Pos2 = b,
        Pos3 = c,
        PosD = d,
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
        local x4, y4 = s.PosD:Unpack()
        rs.AddQuad(layerId, x1, y1, x2, y2, x3, y3, x4, y4)
    end

    return setmetatable(s, Quad)
end

return Quad
