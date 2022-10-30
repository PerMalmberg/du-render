---@module "Props"
---@module "Screen"

local Vec2 = require("Vec2")
local Text = require("Text")
local Image = require("Image")
local Box = require("Box")
local rs = require("RenderScript").Instance()

---@class Layer
---@field New fun():Layer
---@field Id integer
---@field Origin Vec2
---@field Rotation number
---@field Scale Vec2
---@field Text fun(text:string, pos:Vec2, font:FontHandle, props:Props):Text
---@field Image fun(url:string, pos:Vec2, props:Props):Image
---@field Box fun(pos:Vec2, dimensions:Vec2, cornerRadius:number, props:Props):Box
---@field Render fun()

local Layer = {}
Layer.__index = Layer

---Create a new layer
---@param screen Screen
---@return Layer
function Layer.New(screen)
    local s = {
        Id = rs.CreateLayer(),
        Origin = Vec2.New(),
        Rotation = 0,
        Scale = Vec2.New(1, 1)
    }

    ---Create a new text on the layer
    ---@param text string
    ---@param pos Vec2
    ---@param font FontHandle
    ---@param props Props
    ---@return Text
    function s.Text(text, pos, font, props)
        local t = Text.New(text, pos, s, font, props)
        screen.Add(t)
        return t
    end

    ---Adds an image to the layer
    ---@param url string
    ---@param pos Vec2
    ---@param props Props
    ---@return Image
    function s.Image(url, pos, props)
        local img = Image.New(url, pos, s, props)
        screen.Add(img)
        return img
    end

    ---Adds a box to the layer
    ---@param pos Vec2
    ---@param dimensions Vec2
    ---@param cornerRadius number
    ---@param props Props
    ---@return Box
    function s.Box(pos, dimensions, cornerRadius, props)
        local b = Box.New(s, pos, dimensions, cornerRadius, props)
        screen.Add(b)
        return b
    end

    function s.Render()
        rs.SetLayerOrigin(s.Id, s.Origin:Unpack())
        rs.SetLayerRotation(s.Id, math.rad(s.Rotation))
        rs.SetLayerScale(s.Id, s.Scale:Unpack())
    end

    return setmetatable(s, Layer)
end

return Layer
