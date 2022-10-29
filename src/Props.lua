local Color = require("Color")
local ColorAndDistance = require("ColorAndDistance")
local TextAlign = require("TextAlign")
local RS = require("RenderScript").Instance()

---@class Props
---@field Fill Color The fill color
---@field Rotation number The rotation, in degrees
---@field Shadow ColorAndDistance The shadow
---@field Stroke ColorAndDistance The stroke color for shapes
---@field Align TextAlign The text alignment for text strings
---@field Apply fun(layer:integer) Applies the properties to the layer
---@field ApplyDefault fun(layer:integer, shape:RSShape) Applies the properties as defaults to the layer

local Props = {}
Props.__index = Props

---Creates a new properties container
---@param color? Color
---@param rotation? number
---@param shadow? ColorAndDistance
---@param stroke? ColorAndDistance
---@param align? TextAlign
---@return Props
function Props.New(color, rotation, shadow, stroke, align)
    local s = {
        Fill = color or Color.Transparent(),
        Rotation = rotation or 0,
        Shadow = shadow or ColorAndDistance.New(Color.Transparent(), 0),
        Stroke = stroke or ColorAndDistance.New(Color.Transparent(), 0),
        Align = align or TextAlign.Default()
    }

    ---Creates a default Props
    ---@return Props
    function Props.Default()
        return Props.New(Color.New(1, 1, 1))
    end

    ---Applies the propertries to the layer
    ---@param layer integer
    function s.Apply(layer)
        RS.SetNextFillColor(layer, s.Fill:Unpack())
        RS.SetNextRotationDegrees(layer, s.Rotation)
        RS.SetNextShadow(layer, s.Shadow.Distance, s.Shadow.Color:Unpack())
        RS.SetNextStrokeColor(layer, s.Stroke.Color:Unpack())
        RS.SetNextStrokeWidth(layer, s.Stroke.Distance)
        RS.SetNextTextAlign(layer, s.Align.Hor, s.Align.Ver)
    end

    ---Applies the propertries as defaults to the layer
    ---@param layer integer
    ---@param shape RSShape
    function s.ApplyDefault(layer, shape)
        RS.SetDefaultFillColor(layer, shape, s.Fill:Unpack())
        RS.SetDefaultRotation(layer, shape, s.Rotation)
        RS.SetDefaultShadow(layer, shape, s.Shadow.Distance, p.Shadow.Color:Unpack())
        RS.SetDefaultStrokeColor(layer, shape, s.Stroke.Color:Unpack())
        RS.SetDefaultStrokeWidth(layer, shape, s.Stroke.Distance)
        RS.SetDefaultTextAlign(layer, s.Align.Hor, s.Align.Ver)
    end

    return setmetatable(s, Props)
end

return Props
