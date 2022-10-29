local rs = require("RenderScript").Instance()
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
    ---@return number, number
    function s.Bounds()
        return rs.GetTextBounds(s.Font, s.Text)
    end

    ---Width of text
    ---@return number
    function s.Width()
        local w, _ = rs.GetTextBounds(s.Font, s.Text)
        return w
    end

    ---Width of text
    ---@return number
    function s.Height()
        local _, h = rs.GetTextBounds(s.Font, s.Text)
        return h
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
