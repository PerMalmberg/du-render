---@alias SimpleModifier fun(any):any

---@class BinderModifier
---@field isMul boolean
---@field isDiv boolean
---@field percentVal number|Vec2
---@field initVal number|Vec2

local BinderModifier = {}
BinderModifier.__index = {}

---@param isMul boolean
---@param isDiv boolean
---@param percentVal number|Vec2
---@param initVal number|Vec2
function BinderModifier.New(isMul, isDiv, percentVal, initVal)
    local s = {
        isMul = isMul,
        isDiv = isDiv,
        percentVal = percentVal,
        initVal = initVal
    }

    return setmetatable(s, BinderModifier)
end

---@param self BinderModifier
---@param mod number|Vec2
---@return number|Vec2
function BinderModifier.__call(self, mod)
    local s = self
    if s.isMul then
        return s.initVal * mod
    elseif s.isDiv then
        return s.initVal / mod
    elseif s.percentVal then
        -- When v is 1, return shall be percentVal
        return s.initVal + (s.percentVal - s.initVal) * mod
    end

    return mod
end

return BinderModifier
