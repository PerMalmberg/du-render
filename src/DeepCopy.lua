-- http://lua-users.org/wiki/CopyTable
-- It is important that only one argument is supplied to this version of the deepcopy function.
-- Otherwise, it will attempt to use the second argument as a table, which can have unintended consequences.
local function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

---Deeply copies the provided table
---@generic T
---@param o T
---@return T
function DeepCopy(o)
    return deepcopy(o)
end

return DeepCopy
