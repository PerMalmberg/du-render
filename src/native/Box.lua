local rs = require("native/RenderScript").Instance()

---@class Box
---@field Pos Vec2
---@field Dimensions Vec2
---@field Props Props
---@field Render fun()
---@field Hit fun(point:Vec2):boolean

local Box = {}
Box.__index = Box

---Creates a new Box
---@param layer Layer
---@param pos Vec2
---@param dimensions Vec2
---@param cornerRadius number
---@param props Props
function Box.New(layer, pos, dimensions, cornerRadius, props)
    local s = {
        Layer = layer,
        Pos = pos,
        Dimensions = dimensions,
        CornerRadius = cornerRadius,
        Props = props
    }

    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)

        local r = s.CornerRadius
        if r and r > 0 then
            rs.AddBoxRounded(layerId, s.Pos.x, s.Pos.y, s.Dimensions.x, s.Dimensions.y, r)
        else
            rs.AddBox(layerId, s.Pos.x, s.Pos.y, s.Dimensions:Unpack())
        end
    end

    --Determines if the position is within the element
    ---@param point Vec2
    ---@return boolean
    function s.Hit(point)
        local max = s.Pos + s.Dimensions
        return point.x >= s.Pos.x and point.x <= max.x
            and point.y >= s.Pos.y and point.y <= max.y
    end

    return setmetatable(s, Box)
end

return Box
