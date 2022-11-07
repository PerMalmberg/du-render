local rs = require("RenderScript").Instance()
local Vec2 = require("Vec2")

---@module "Color"
---@module "Font"

---@class Text
---@field Text string
---@field Pos Vec2
---@field Font FontHandle
---@field Layer Layer
---@field Props Props
---@field Bounds fun():number, number
---@field Width fun():number
---@field Height fun():number
---@field Render fun()
---@field Hit fun(point:Vec2):boolean

local Text = {}
Text.__index = Text

---Creates a new Text
---@param text string
---@param pos Vec2
---@param layer Layer
---@param font FontHandle
---@param props Props
---@return Text
function Text.New(text, pos, layer, font, props)
    local s = {
        Text = text,
        Pos = pos,
        Font = font,
        Props = props,
        Layer = layer
    }

    ---Returns the width and height, in pixels the text occupies.
    ---@return Vec2
    function s.Bounds()
        return Vec2.New(rs.GetTextBounds(s.Font, s.Text))
    end

    ---Width of text
    ---@return number
    function s.Width()
        return s.Bounds().x
    end

    ---Width of text
    ---@return number
    function s.Height()
        return s.Bounds().y
    end

    ---Renders the text
    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        rs.AddText(layerId, s.Font, s.Text, s.Pos:Unpack())
    end

    --Determines if the position is within the element
    ---@param point Vec2
    ---@return boolean
    function s.Hit(point)
        local max = s.Pos + s.Bounds()
        return point.x >= s.Pos.x and point.x <= max.x
            and point.y >= s.Pos.y and point.y <= max.y
    end

    return setmetatable(s, Text)
end

return Text
