local rs = require("RenderScript").Instance()
local Vec2 = require("Vec2")

---@module "Color"
---@module "Font"

---@class Text
---@field Text string
---@field X number
---@field Y number
---@field Font FontHandle
---@field Layer Layer
---@field Props Props
---@field Bounds fun():number, number
---@field Width fun():number
---@field Height fun():number
---@field Render fun()

local Text = {}
Text.__index = Text

---Creates a new Text
---@param text string
---@param x number
---@param y number
---@param layer Layer
---@param font FontHandle
---@param props Props
---@return Text
function Text.New(text, x, y, layer, font, props)
    local s = {
        Text = text,
        X = x,
        Y = y,
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
        rs.AddText(layerId, s.Font, s.Text, s.X, s.Y)
    end

    return setmetatable(s, Text)
end

return Text
