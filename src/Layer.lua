---@module "Props"
---@module "Screen"

local Text = require("Text")
local rs = require("RenderScript").Instance()

---@class Layer
---@field New fun():Layer
---@field Id integer
---@field Text fun(text:string, x:number, y:number, font:FontHandle, props:Props):Text

local Layer = {}
Layer.__index = Layer

---Create a new layer
---@param screen Screen
---@return Layer
function Layer.New(screen)
    local s = {
        Id = rs.CreateLayer()
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

    return setmetatable(s, Layer)
end

return Layer
