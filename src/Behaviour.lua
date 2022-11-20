local rs = require("native/RenderScript").Instance()
local Vec2 = require("native/Vec2")

---@enum MouseState
MouseState = {
    Click = 1,
    MouseDown = 2,
    MouseUp = 3,
    MouseInside = 4,
    MouseOutside = 5
}

---@alias HitFunc fun(pos:Vec2):boolean
---@alias InteractibleElement {Hit:HitFunc}
---@alias ClickHandler fun(element:InteractibleElement, event:MouseState)
---@alias BooleanMouseContainer {obj:table, handler:ClickHandler}
---@alias MouseHandler fun(element:InteractibleElement, handler:ClickHandler)

---@class Behaviour
---@field New fun():Behaviour
---@field Clear fun()
---@field OnMouseClick MouseHandler
---@field OnMouseDownOrUp MouseHandler
---@field OnMouseInsideOrOutside MouseHandler

local Behaviour = {}
Behaviour.__index = Behaviour

function Behaviour.New()
    local s = {}

    local onMouseClick = {} ---@type BooleanMouseContainer[]
    local onMouseDownOrUp = {} ---@type BooleanMouseContainer[]
    local onMouseInSideorOutside = {} ---@type BooleanMouseContainer[]

    ---Registers the element for mouse click events
    ---@param element InteractibleElement
    ---@param handler ClickHandler
    function s.OnMouseClick(element, handler)
        table.insert(onMouseClick, { obj = element, handler = handler })
    end

    ---Registers the element for mouse down and/or up events
    ---@param element InteractibleElement
    ---@param handler ClickHandler
    function s.OnMouseDownOrUp(element, handler)
        table.insert(onMouseDownOrUp, { obj = element, handler = handler })
    end

    ---Registers the element for mouse inside and/or outside events
    ---@param element InteractibleElement
    ---@param handler ClickHandler
    function s.OnMouseInsideOrOutside(element, handler)
        table.insert(onMouseInSideorOutside, { obj = element, handler = handler })
    end

    ---Triggers events
    ---@param screen Screen
    function s.TriggerEvents(screen)
        local pressed = rs.GetCursorPressed()
        local down = rs.GetCursorDown()

        local hitElement = screen.DetermineHitElement()

        for _, cont in ipairs(onMouseClick) do
            if pressed and hitElement == cont.obj then
                cont.handler(cont.obj, MouseState.Click)
            end
        end

        for _, cont in ipairs(onMouseDownOrUp) do
            if down and hitElement == cont.obj then
                cont.handler(cont.obj, MouseState.MouseDown)
            else
                cont.handler(cont.obj, MouseState.MouseUp)
            end
        end

        for _, cont in ipairs(onMouseInSideorOutside) do
            if hitElement == cont.obj then
                cont.handler(cont.obj, MouseState.MouseInside)
            else
                cont.handler(cont.obj, MouseState.MouseOutside)
            end
        end
    end

    function s.Clear()
        onMouseClick = {}
        onMouseDownOrUp = {}
        onMouseInSideorOutside = {}
    end

    return setmetatable(s, Behaviour)
end

return Behaviour
