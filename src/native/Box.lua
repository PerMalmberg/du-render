local rs = require("native/RenderScript").Instance()

---@class Box
---@field Pos1 Vec2
---@field Pos2 Vec2
---@field Props Props
---@field Visible boolean
---@field Render fun()
---@field Hit fun(point:Vec2):boolean

local Box = {}
Box.__index = Box

---Creates a new Box
---@param layer Layer
---@param pos1 Vec2
---@param pos2 Vec2
---@param cornerRadius number
---@param props Props
function Box.New(layer, pos1, pos2, cornerRadius, props)
    local s = {
        Layer = layer,
        Pos1 = pos1,
        Pos2 = pos2,
        CornerRadius = cornerRadius,
        Props = props,
        Visible = true
    }

    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)

        -- The RenderScript API wants positon and width/hight
        local dimensions = s.Pos2 - s.Pos1

        local r = s.CornerRadius
        if r and r > 0 then
            rs.AddBoxRounded(layerId, s.Pos1.x, s.Pos1.y, dimensions.x, dimensions.y, r)
        else
            rs.AddBox(layerId, s.Pos1.x, s.Pos1.y, dimensions.x, dimensions.y)
        end
    end

    --Determines if the position is within the element
    ---@param point Vec2
    ---@return boolean
    function s.Hit(point)
        local min = s.Pos1
        local max = s.Pos2
        return point.x >= min.x and point.x <= max.x
            and point.y >= min.y and point.y <= max.y
    end

    return setmetatable(s, Box)
end

return Box
