local Color = require("Color")
local ColorAndDistance = require("ColorAndDistance")
local TextAlign = require("TextAlign")
local rs = require("RenderScript").Instance()

---@alias PropsTableStruct {fill:string, rotation:number, shadow: {color:string, distance:number}, stroke:{color:string, distance:number}, align:string}

---@class Props
---@field Fill Color The fill color
---@field Rotation number The rotation, in degrees
---@field Shadow ColorAndDistance The shadow
---@field Stroke ColorAndDistance The stroke color for shapes
---@field Align TextAlign The text alignment for text strings
---@field Apply fun(layer:integer) Applies the properties to the layer
---@field ApplyDefault fun(layer:integer, shape:RSShape) Applies the properties as defaults to the layer
---@field Clone fun():Props
---@field Load fun(input:PropsTableStruct):Props Loads a Props from a table
---@field Persist fun():PropsTableStruct

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

    ---Applies the propertries to the layer
    ---@param layer integer
    function s.Apply(layer)
        rs.SetNextFillColor(layer, s.Fill:Unpack())
        rs.SetNextRotationDegrees(layer, s.Rotation)
        rs.SetNextShadow(layer, s.Shadow.Distance, s.Shadow.Color:Unpack())
        rs.SetNextStrokeColor(layer, s.Stroke.Color:Unpack())
        rs.SetNextStrokeWidth(layer, s.Stroke.Distance)
        rs.SetNextTextAlign(layer, s.Align.Hor, s.Align.Ver)
    end

    ---Applies the propertries as defaults to the layer
    ---@param layer integer
    ---@param shape RSShape
    function s.ApplyDefault(layer, shape)
        rs.SetDefaultFillColor(layer, shape, s.Fill:Unpack())
        rs.SetDefaultRotation(layer, shape, s.Rotation)
        rs.SetDefaultShadow(layer, shape, s.Shadow.Distance, s.Shadow.Color:Unpack())
        rs.SetDefaultStrokeColor(layer, shape, s.Stroke.Color:Unpack())
        rs.SetDefaultStrokeWidth(layer, shape, s.Stroke.Distance)
        rs.SetDefaultTextAlign(layer, s.Align.Hor, s.Align.Ver)
    end

    ---Deeply clones a Props
    function s.Clone()
        return Props.New(Color.Clone(), s.Rotation, s.Shadow.Clone(), s.Stroke.Clone(), s.TextAlign.Clone())
    end

    ---Creates a table with data ready to persist
    ---@return PropsTableStruct
    function s.Persist()
        local t = {
            fill = s.Fill.ToString(),
            align = s.Align.ToString(),
            rotation = s.Rotation,
            shadow = { color = s.Shadow.Color.ToString(), distance = s.Shadow.Distance },
            stroke = { color = s.Stroke.Color.ToString(), distance = s.Stroke.Distance }
        }

        return t
    end

    return setmetatable(s, Props)
end

---Creates a default Props
---@return Props
function Props.Default()
    return Props.New(Color.New(1, 1, 1))
end

---Loads a Props from the table (all lower case keys)
---@param input PropsTableStruct
---@return Props
function Props.Load(input)
    -- Load the different parts that makes up a Props and return a new one.
    local color = Color.FromString(input.fill) or Color.Transparent()
    local rotation = input.rotation or 0
    local shadowColor, shadowDist
    if input.shadow then
        shadowColor = Color.FromString(input.shadow.color)
        shadowDist = input.shadow.distance
    end

    local shadow
    if shadowColor and shadowDist then
        shadow = ColorAndDistance.New(shadowColor, shadowDist)
    else
        shadow = ColorAndDistance.New(Color.Transparent(), 0)
    end

    local strokeColor, strokeDist
    if input.stroke then
        strokeColor = Color.FromString(input.stroke.color)
        strokeDist = input.stroke.distance
    end

    local stroke
    if strokeColor and strokeDist then
        stroke = ColorAndDistance.New(strokeColor, strokeDist)
    else
        stroke = ColorAndDistance.New(Color.Transparent(), 0)
    end

    local align = TextAlign.FromString(input.align)

    return Props.New(color, rotation, shadow, stroke, align)
end

return Props
