local rs = require("RenderScript").Instance()
local Vec2 = require("Vec2")

---@enum MouseEvent
MouseEvent = {
    Click = 1,
    MouseDown = 2,
    MouseUp = 3,
    MouseEnter = 4,
    MouseLeave = 5
}

---@alias HitFunc fun(pos:Vec2):boolean
---@alias InteractibleElement {Hit:HitFunc, Props:Props}
---@alias ClickHandler fun(element:InteractibleElement, event:MouseEvent)
---@alias BooleanMouseContainer {obj:table, handler:ClickHandler}

---@class Behaviour
---@field OnMouseDown fun(element:InteractibleElement, handler:ClickHandler)


local Behaviour = {}
Behaviour.__index = Behaviour

function Behaviour.New()
    local s = {}

    local onMouseDownOrUp = {} ---@type BooleanMouseContainer[]
    local onMouseEnterOrLeave = {} ---@type BooleanMouseContainer[]

    ---Registers the element for mouse down events
    ---@param element InteractibleElement
    ---@param handler ClickHandler
    function s.OnMouseDownOrUp(element, handler)
        table.insert(onMouseDownOrUp, { obj = element, handler = handler })
    end

    ---Registers the element for mouse enter events
    ---@param element InteractibleElement
    ---@param handler ClickHandler
    function s.OnMouseEnterOrLeave(element, handler)
        table.insert(onMouseEnterOrLeave, { obj = element, handler = handler })
    end

    ---Triggers events
    ---@param screen Screen
    function s.TriggerEvents(screen)
        local up = rs.GetCursorReleased()
        local down = rs.GetCursorDown()

        local hitElement = screen.DetermineHitElement()

        if up or down then
            for _, cont in ipairs(onMouseDownOrUp) do
                if down and hitElement == cont.obj then
                    cont.handler(cont.obj, MouseEvent.MouseDown)
                else
                    cont.handler(cont.obj, MouseEvent.MouseUp)
                end
            end
        end

        for _, cont in ipairs(onMouseEnterOrLeave) do
            if hitElement == cont.obj then
                cont.handler(cont.obj, MouseEvent.MouseEnter)
            else
                cont.handler(cont.obj, MouseEvent.MouseLeave)
            end
        end
    end

    return setmetatable(s, Behaviour)
end

return Behaviour
