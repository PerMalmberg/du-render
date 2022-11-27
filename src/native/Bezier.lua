local rs = require("native/RenderScript").Instance()

---@class Bezier
---@field Pos1 Vec2
---@field Pos2 Vec2
---@field Pos3 Vec2
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
        Pos1 = a,
        Pos2 = b,
        Pos3 = c,
        Props = props
    }

    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        local x1, y1 = s.Pos1:Unpack()
        local x2, y2 = s.Pos2:Unpack()
        local x3, y3 = s.Pos3:Unpack()
        rs.AddBezier(layerId, x1, y1, x2, y2, x3, y3)
    end

    return setmetatable(s, Bezier)
end

return Bezier
