local Color   = require("native/Color")
local Vec2    = require("native/Vec2")
local getTime = require("native/RenderScript").Instance().GetTime
---@module "BinderModifier"

---@class BindPath
---@field New fun(parts:string[]):BindPath
---@field Text fun(o:table, propertyName:string, valueName:string, format?:string, interval?:number, modifier?:fun(t:string):string)
---@field Number fun(o:table, propertyName:string, valueName:string, format?:string, interval?:number, modifier?:BinderModifier|SimpleModifier)
---@field Color fun(o:table, propertyName:string, valueName:string, interval?:number, modifier?:fun(c:Color):Color)
---@field Vec2 fun(o:table, propertyName:string, valueName:string, interval?:number, modifier?:BinderModifier|SimpleModifier)
---@field ProcessNumber fun(propertyName:string, value:number)
---@field ProcessVec2 fun(propertyName:string, value:Vec2)
---@field ProcessText fun(propertyName:string, value:string)
---@field ProcessColor fun(propertyName:string, value:string)

---@alias genericModifier fun(any):any
---@alias BoundText {obj:table, propertyName:string, valueName:string, updateInterval:number, format:string, modifier:genericModifier, lastUpdate:number}
---@alias BoundNumber {obj:table, propertyName:string, valueName:string, updateInterval:number, format:string, modifier:BinderModifier, lastUpdate:number}

local BindPath = {}
BindPath.__index = BindPath

local function noop(v)
    return v
end

---Creates a new BindPath
---@param updateInterval number
---@return BindPath
function BindPath.New(updateInterval)
    local s = {}
    local boundText = {} ---@type BoundText[]
    local boundNumber = {} ---@type BoundNumber[]
    local boundColor = {} ---@type BoundText[]
    local boundVec2 = {} ---@type BoundText[]

    ---Binds a text property
    ---@param obj table
    ---@param propertyName string
    ---@param valueName string
    ---@param format? string
    ---@param interval? number
    ---@param modifier? fun(t:string):string
    function s.Text(obj, propertyName, valueName, format, interval, modifier)
        table.insert(boundText, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName,
            format = format or "%s",
            lastUpdate = 0,
            updateInterval = interval or updateInterval,
            modifier = modifier or noop
        })
    end

    ---Binds a number property
    ---@param obj table
    ---@param propertyName string
    ---@param valueName string
    ---@param format string|nil If provided, this is used to format the resulting value into a string instead of a number.
    ---@param interval? number
    ---@param modifier? BinderModifier
    function s.Number(obj, propertyName, valueName, format, interval, modifier)
        table.insert(boundNumber, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName,
            format = format,
            lastUpdate = 0,
            updateInterval = interval or updateInterval,
            modifier = modifier or noop
        })
    end

    ---Binds a number property
    ---@param obj table
    ---@param propertyName string
    ---@param valueName string
    ---@param interval? number
    ---@param modifier? fun(t:string):string
    function s.Color(obj, propertyName, valueName, interval, modifier)
        table.insert(boundColor, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName,
            lastUpdate = 0,
            updateInterval = interval or updateInterval,
            modifier = modifier or noop
        })
    end

    ---Binds a Vec2 property
    ---@param obj table
    ---@param propertyName string
    ---@param valueName string
    ---@param interval? number
    ---@param modifier? BinderModifier
    function s.Vec2(obj, propertyName, valueName, interval, modifier)
        table.insert(boundVec2, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName,
            lastUpdate = 0,
            updateInterval = interval or updateInterval,
            modifier = modifier or noop
        })
    end

    function s.ProcessNumber(valueName, value)
        local now = getTime()
        for _, bind in ipairs(boundNumber) do
            if bind.valueName == valueName and now - bind.lastUpdate >= bind.updateInterval then
                local modified = bind.modifier(value)
                if bind.format then
                    -- When providing a format it turns the resulting value into a string instead of a number.
                    modified = string.format(bind.format, modified)
                end
                bind.obj[bind.propertyName] = modified
            end
        end
    end

    ---@param valueName string
    ---@param value Vec2
    function s.ProcessVec2(valueName, value)
        local now = getTime()

        for _, bind in ipairs(boundVec2) do
            if bind.valueName == valueName and now - bind.lastUpdate >= bind.updateInterval then
                bind.obj[bind.propertyName] = bind.modifier(value)
                bind.lastUpdate = now
            end
        end
    end

    function s.ProcessText(valueName, value)
        local now = getTime()
        for _, bind in ipairs(boundText) do
            if bind.valueName == valueName and now - bind.lastUpdate >= bind.updateInterval then
                bind.obj[bind.propertyName] = string.format(bind.format, tostring(bind.modifier(value)))
                bind.lastUpdate = now
            end
        end

        local c = Color.FromString(value)
        if c then
            for _, bind in ipairs(boundColor) do
                if bind.valueName == valueName and now - bind.lastUpdate >= bind.updateInterval then
                    bind.obj[bind.propertyName] = bind.modifier(c)
                    bind.lastUpdate = now
                end
            end
        end

        local v = Vec2.FromString(value)
        if v then
            s.ProcessVec2(valueName, v)
        end
    end

    return setmetatable(s, BindPath)
end

return BindPath
