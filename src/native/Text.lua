local rs = require("native/RenderScript").Instance()
local abs = math.abs
local Vec2 = require("native/Vec2")

---@module "Color"
---@module "Font"

---@class Text
---@field Text string
---@field Pos1 Vec2
---@field Font FontHandle
---@field Layer Layer
---@field Props Props
---@field Bounds fun():number, number
---@field Width fun():number
---@field Height fun():number
---@field Visible boolean
---@field Hitable boolean
---@field GetHitBoxOffset fun():Vec2
---@field Render fun()
---@field Hit fun(point:Vec2):boolean

local Text = {}
Text.__index = Text

---Creates a new Text
---@param text string
---@param pos Vec2
---@param layer Layer
---@param font LoadedFont
---@param props Props
---@return Text
function Text.New(text, pos, layer, font, props)
    local s = {
        Text = text or "",
        Pos1 = pos,
        Font = font,
        Props = props,
        Layer = layer,
        Visible = true,
        Hitable = true
    }

    ---Returns the width and height, in pixels the text occupies.
    ---@return Vec2
    function s.Bounds()
        return rs.GetTextBounds(s.Font, s.Text)
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
        rs.AddText(layerId, s.Font.GetID(), s.Text, s.Pos1:Unpack())
    end

    ---Gets the hitbox offset, as adjusted by the text alignment.
    ---@return Vec2
    function s.GetHitBoxOffset()
        local fontId = s.Font.GetID()
        local ascender, descender = rs.GetFontMetrics(fontId)
        local height = rs.GetFontSize(fontId)
        local horAlign = s.Props.Align.Hor
        local verAlign = s.Props.Align.Ver

        local xOffset = 0
        if horAlign == RSAlignHor.Center then
            xOffset = -s.Bounds().x / 2
        elseif horAlign == RSAlignHor.Right then
            xOffset = -s.Bounds().x
        end

        local yOffset = 0
        if verAlign == RSAlignVer.Ascender then
            yOffset = height - ascender
        elseif verAlign == RSAlignVer.Top then
            yOffset = 0
        elseif verAlign == RSAlignVer.Middle then
            yOffset = -s.Bounds().y / 2
        elseif verAlign == RSAlignVer.Baseline then
            yOffset = -ascender
        elseif verAlign == RSAlignVer.Bottom then
            yOffset = -height + descender
        elseif verAlign == RSAlignVer.Descender then
            yOffset = -height + descender
        end

        return Vec2.New(xOffset, yOffset)
    end

    --Determines if the position is within the element
    ---@param point Vec2
    ---@return boolean
    function s.Hit(point)
        -- Alignment affects the position of the string so we must take care of that here.
        local upperLeft = s.Pos1 + s.GetHitBoxOffset()
        local lowerRight = upperLeft + s.Bounds()

        return s.Hitable and s.Visible
            and point.x >= upperLeft.x and point.x <= lowerRight.x
            and point.y >= upperLeft.y and point.y <= lowerRight.y
    end

    return setmetatable(s, Text)
end

return Text
