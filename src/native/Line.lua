local rs = require("native/RenderScript").Instance()

---@class Line
---@field Pos1 Vec2
---@field Pos2 Vec2
---@field Props Props
---@field Visible boolean
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
        Pos1 = a,
        Pos2 = b,
        Props = props,
        Visible = true
    }

    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        local x1, y1 = s.Pos1:Unpack()
        local x2, y2 = s.Pos2:Unpack()
        rs.AddLine(layerId, x1, y1, x2, y2)
    end

    return setmetatable(s, Line)
end

return Line
