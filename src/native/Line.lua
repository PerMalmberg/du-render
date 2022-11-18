local rs = require("native/RenderScript").Instance()

---@class Line
---@field PosA Vec2
---@field PosB Vec2
---@field Props Props
---@field Render fun()

local Line = {}
Line.__index = Line

---Creates a new Line
---@param layer Layer
---@param a Vec2
---@param b Vec2
---@param props Props
function Line.New(layer, a, b, props)
    local s = {
        Layer = layer,
        PosA = a,
        PosB = b,
        Props = props
    }

    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        local x1, y1 = s.PosA:Unpack()
        local x2, y2 = s.PosB:Unpack()
        rs.AddLine(layerId, x1, y1, x2, y2)
    end

    return setmetatable(s, Line)
end

return Line
