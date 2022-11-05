local Color = require("Color")
local Vec2  = require("Vec2")

---@class BindPath
---@field New fun(parts:string[]):BindPath
---@field Text fun(o:table, propertyName:string, valueName:string)
---@field Color fun(o:table, propertyName:string, valueName:string)
---@field Vec2 fun(o:table, propertyName:string, valueName:string)
---@field Number fun(o:table, propertyName, valueName:string, format:string)
---@field ProcessNumber fun(propertyName:string, value:number)
---@field ProcessText fun(propertyName:string, value:string)
---@field ProcessColor fun(propertyName:string, value:string)

---@alias BoundText {obj:table, propertyName:string, valueName:string}
---@alias BoundNumber {obj:table, propertyName:string, valueName:string, format:string}

local BindPath = {}
BindPath.__index = BindPath

---Creates a new BindPath
---@return BindPath
function BindPath.New()
    local s = {}
    local boundText = {} ---@type BoundText[]
    local boundNumber = {} ---@type BoundNumber[]
    local boundColor = {} ---@type BoundText[]
    local boundVec2 = {} ---@BoundText[]

    function s.Text(obj, propertyName, valueName)
        table.insert(boundText, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName
        })
    end

    function s.Number(obj, propertyName, valueName, format)
        table.insert(boundNumber, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName,
            format = format
        })
    end

    function s.Color(obj, propertyName, valueName)
        table.insert(boundColor, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName
        })
    end

    function s.Vec2(obj, propertyName, valueName)
        table.insert(boundVec2, {
            obj = obj,
            propertyName = propertyName,
            valueName = valueName
        })
    end

    function s.ProcessNumber(valueName, value)
        for _, bind in ipairs(boundNumber) do
            if bind.valueName == valueName then
                bind.obj[bind.propertyName] = string.format(bind.format or "%f", value)
            end
        end
    end

    function s.ProcessText(valueName, value)
        for _, bind in ipairs(boundText) do
            if bind.valueName == valueName then
                bind.obj[bind.propertyName] = value
            end
        end


        local c = Color.FromString(value)
        if c then
            for _, bind in ipairs(boundColor) do
                if bind.valueName == valueName then
                    bind.obj[bind.propertyName] = c
                end
            end
        end

        local v = Vec2.FromString(value)
        if v then
            for _, bind in ipairs(boundVec2) do
                if bind.valueName == valueName then
                    bind.obj[bind.propertyName] = v
                end
            end
        end
    end

    return setmetatable(s, BindPath)
end

return BindPath
