local Color   = require("native/Color")
local Vec2    = require("native/Vec2")
local getTime = require("native/RenderScript").Instance().GetTime

---@class BindPath
---@field New fun(parts:string[]):BindPath
---@field Text fun(o:table, propertyName:string, valueName:string)
---@field Color fun(o:table, propertyName:string, valueName:string)
---@field Vec2 fun(o:table, propertyName:string, valueName:string)
---@field Number fun(o:table, propertyName:string, valueName:string, format:string)
---@field ProcessNumber fun(propertyName:string, value:number)
---@field ProcessText fun(propertyName:string, value:string)
---@field ProcessColor fun(propertyName:string, value:string)

---@alias BoundText {obj:table, propertyName:string, valueName:string, updateInterval:number, lastUpdate:number}
---@alias BoundNumber {obj:table, propertyName:string, valueName:string, format:string, updateInterval:number, lastUpdate:number}

local BindPath = {}
BindPath.__index = BindPath

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
    ---@param interval? number
    function s.Text(obj, propertyName, valueName, interval)
        table.insert(boundText, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName,
            lastUpdate = 0,
            updateInterval = interval or updateInterval
        })
    end

    ---Binds a number property
    ---@param obj table
    ---@param propertyName string
    ---@param valueName string
    ---@param format string
    ---@param interval? number
    function s.Number(obj, propertyName, valueName, format, interval)
        table.insert(boundNumber, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName,
            format = format,
            lastUpdate = 0,
            updateInterval = interval or updateInterval
        })
    end

    ---Binds a number property
    ---@param obj table
    ---@param propertyName string
    ---@param valueName string
    ---@param interval? number
    function s.Color(obj, propertyName, valueName, interval)
        table.insert(boundColor, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName,
            lastUpdate = 0,
            updateInterval = interval or updateInterval
        })
    end

    ---Binds a number property
    ---@param obj table
    ---@param propertyName string
    ---@param valueName string
    ---@param interval? number
    function s.Vec2(obj, propertyName, valueName, interval)
        table.insert(boundVec2, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName,
            lastUpdate = 0,
            updateInterval = interval or updateInterval
        })
    end

    function s.ProcessNumber(valueName, value)
        local now = getTime()
        for _, bind in ipairs(boundNumber) do
            if bind.valueName == valueName and now - bind.lastUpdate >= bind.updateInterval then
                bind.obj[bind.propertyName] = string.format(bind.format or "%f", value)
            end
        end
    end

    function s.ProcessText(valueName, value)
        local now = getTime()
        for _, bind in ipairs(boundText) do
            if bind.valueName == valueName and now - bind.lastUpdate >= bind.updateInterval then
                bind.obj[bind.propertyName] = value
                bind.lastUpdate = now
            end
        end


        local c = Color.FromString(value)
        if c then
            for _, bind in ipairs(boundColor) do
                if bind.valueName == valueName and now - bind.lastUpdate >= bind.updateInterval then
                    bind.obj[bind.propertyName] = c
                    bind.lastUpdate = now
                end
            end
        end

        local v = Vec2.FromString(value)
        if v then
            for _, bind in ipairs(boundVec2) do
                if bind.valueName == valueName and now - bind.lastUpdate >= bind.updateInterval then
                    bind.obj[bind.propertyName] = v
                    bind.lastUpdate = now
                end
            end
        end
    end

    return setmetatable(s, BindPath)
end

return BindPath
