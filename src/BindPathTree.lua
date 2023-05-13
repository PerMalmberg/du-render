---@module "BindPath"

---@class BindPathTree
---@field Sub table<string,BindPathTree>
---@field Bind BindPath[]

local BindPathTree = {}
BindPathTree.__index = BindPathTree

---@return BindPathTree
function BindPathTree.New()
    local s = {
        Sub = {}, ---@type table<string,BindPathTree>
        Bind = {} ---@type BindPath[]
    }

    return setmetatable(s, BindPathTree)
end

return BindPathTree
