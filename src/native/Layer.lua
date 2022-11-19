---@module "Screen"

local rs = require("native/RenderScript").Instance()
local Vec2 = require("native/Vec2")
local Text = require("native/Text")
local Image = require("native/Image")
local Box = require("native/Box")
local Bezier = require("native/Bezier")
local Circle = require("native/Circle")
local Line = require("native/Line")
local Triangle = require("native/Triangle")
local Quad = require("native/Quad")
local Props = require("native/Props")

---@class Layer
---@field New fun():Layer
---@field Id integer
---@field Origin Vec2
---@field Rotation number
---@field Scale Vec2
---@field Text fun(text:string, pos:Vec2, font:FontHandle, props:Props?):Text
---@field Image fun(url:string, pos:Vec2, props:Props):Image
---@field Box fun(pos:Vec2, dimensions:Vec2, cornerRadius:number, props:Props?):Box
---@field Bezier fun(a:Vec2, b:Vec2, c:Vec2, props:Props?):Bezier
---@field Line fun(a:Vec2, b:Vec2, props:Props?):Line
---@field Triangle fun(a:Vec2, b:Vec2, c:Vec2, props:Props?):Triangle
---@field Circle fun(pos:Vec2, radius:number, props:Props?):Circle
---@field Quad fun(a:Vec2, b:Vec2, c:Vec2, d:Vec2, props:Props?):Quad
---@field Render fun()
---@field DetermineHitElement fun(cursor:Vec2):table

local Layer = {}
Layer.__index = Layer

---Create a new layer
---@return Layer
function Layer.New()
    local s = {
        Id = rs.CreateLayer(),
        Origin = Vec2.New(),
        Rotation = 0,
        Scale = Vec2.New(1, 1),
        Components = {} ---@type table[]
    }

    ---Create a new text on the layer
    ---@param text string
    ---@param pos Vec2
    ---@param font FontHandle
    ---@param props Props?
    ---@return Text
    function s.Text(text, pos, font, props)
        local t = Text.New(text, pos, s, font, props or Props.Default())
        table.insert(s.Components, t)
        return t
    end

    ---Adds an image to the layer
    ---@param url string
    ---@param pos Vec2
    ---@param dimensions Vec2
    ---@param props Props?
    ---@return Image
    function s.Image(url, pos, dimensions, props)
        local img = Image.New(url, pos, dimensions, s, props or Props.Default())
        table.insert(s.Components, img)
        return img
    end

    ---Adds a box to the layer
    ---@param pos Vec2
    ---@param dimensions Vec2
    ---@param cornerRadius number
    ---@param props Props?
    ---@return Box
    function s.Box(pos, dimensions, cornerRadius, props)
        local b = Box.New(s, pos, dimensions, cornerRadius, props or Props.Default())
        table.insert(s.Components, b)
        return b
    end

    ---Adds a bezier to the layer
    ---@param a Vec2
    ---@param b Vec2
    ---@param c Vec2
    ---@param props Props?
    ---@return Bezier
    function s.Bezier(a, b, c, props)
        local bezier = Bezier.New(s, a, b, c, props or Props.Default())
        table.insert(s.Components, bezier)
        return bezier
    end

    ---Adds a circle to the layer
    ---@param pos Vec2
    ---@param radius number
    ---@param props Props?
    ---@return Circle
    function s.Circle(pos, radius, props)
        local circle = Circle.New(s, pos, radius, props or Props.Default())
        table.insert(s.Components, circle)
        return circle
    end

    ---Adds a line to the layer
    ---@param a Vec2
    ---@param b Vec2
    ---@param props Props?
    ---@return Line
    function s.Line(a, b, props)
        local line = Line.New(s, a, b, props or Props.Default())
        table.insert(s.Components, line)
        return line
    end

    ---Adds a Quad to the layer
    ---@param a Vec2
    ---@param b Vec2
    ---@param c Vec2
    ---@param d Vec2
    ---@param props Props?
    ---@return Quad
    function s.Quad(a, b, c, d, props)
        local quad = Quad.New(s, a, b, c, d, props or Props.Default())
        table.insert(s.Components, quad)
        return quad
    end

    ---Adds a Triangle to the layer
    ---@param a Vec2
    ---@param b Vec2
    ---@param c Vec2
    ---@param props Props?
    ---@return Triangle
    function s.Triangle(a, b, c, props)
        local triangle = Triangle.New(s, a, b, c, props or Props.Default())
        table.insert(s.Components, triangle)
        return triangle
    end

    function s.Render()
        s.Id = rs.CreateLayer() -- Refresh the id on each render
        rs.SetLayerOrigin(s.Id, s.Origin:Unpack())
        rs.SetLayerRotation(s.Id, math.rad(s.Rotation))
        rs.SetLayerScale(s.Id, s.Scale:Unpack())

        for _, comp in ipairs(s.Components) do
            comp.Render()
        end
    end

    ---Determines which element that is hit
    ---@param cursor Vec2
    ---@return table|nil
    function s.DetermineHitElement(cursor)
        for _, component in ipairs(s.Components) do
            if type(component.Hit) == "function" then
                if component.Hit(cursor) then
                    return component
                end
            end
        end

        return nil
    end

    return setmetatable(s, Layer)
end

return Layer
