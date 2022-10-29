---@module "Props"
---@module "Screen"

local Vec2 = require("Vec2")
local Text = require("Text")
local rs = require("RenderScript").Instance()

---@class Layer
---@field New fun():Layer
---@field Id integer
---@field Origin Vec2
---@field Rotation number
---@field Scale Vec2
---@field Text fun(text:string, x:number, y:number, font:FontHandle, props:Props):Text
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
    ---@param x number
    ---@param y number
    ---@param font FontHandle
    ---@param props Props
    ---@return Text
    function s.Text(text, x, y, font, props)
        local t = Text.New(text, x, y, s, font, props)
        screen.Add(t)
        return t
    end

    function s.Render()
        rs.SetLayerOrigin(s.Id, s.Origin:Unpack())
        rs.SetLayerRotation(s.Id, math.rad(s.Rotation))
        rs.SetLayerScale(s.Id, s.Scale:Unpack())
    end

    return setmetatable(s, Layer)
end

return Layer
