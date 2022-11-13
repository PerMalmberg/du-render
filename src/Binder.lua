local BindPath = require("BindPath")
local BindPathTree = require("BindPathTree")

---@class Binder
---@field New fun():Binder
---@field Path fun(path:string):BindPath
---@field MergeData fun(data:table)
---@field Render fun()

local Binder = {}
Binder.__index = {}

---Creates a new Binder
---@return Binder
function Binder.New()
    local s = {}
    local tree = BindPathTree.New()

    ---Creates a BindPath
    ---@param path string The json-path in the data to the object holding the data to bind to, such as "a/b" or just "" for the root object, Only a-z, A-Z and _ are allowed.
    ---@return BindPath
    function s.Path(path)
        -- Build a tree for the paths
        local curr = tree
        for nodeName in string.gmatch(path, "[a-zA-Z_]+") do
            if not curr.Sub[nodeName] then
                curr.Sub[nodeName] = BindPathTree.New()
            end
            curr = curr.Sub[nodeName]
        end

        local p = BindPath.New()
        table.insert(curr.Bind, p)
        return p
    end

    ---@param data table
    ---@param branch BindPathTree
    local function apply(data, branch)
        -- Iterate each key in the data
        for key, value in pairs(data) do
            local t = type(value)
            if t == "table" then
                -- If there is a matching entry in the BindPath tree, go into that
                local p = branch.Sub[key]
                if p then
                    apply(value, p)
                end
            elseif t == "number" then
                for _, bind in pairs(branch.Bind) do
                    bind.ProcessNumber(key, value)
                end
            elseif t == "string" then
                for _, bind in pairs(branch.Bind) do
                    bind.ProcessText(key, value)
                end
            end
        end
    end

    local function merge(target, source)
        for sourceKey, sourceValue in pairs(source) do
            local t = type(sourceValue)
            if t ~= "function" then
                if t == "table" then
                    if not target[sourceKey] then
                        target[sourceKey] = {}
                    end

                    merge(target[sourceKey], sourceValue)
                else
                    target[sourceKey] = sourceValue
                end
            end
        end
    end

    ---Merges the given data with the data previously provided
    ---@param data table
    function s.MergeData(data)
        if not _ENV.binderData then
            _ENV.binderData = {}
        end

        merge(_ENV.binderData, data)
    end

    ---Sets the data, discarding any previously merged data.
    ---@param data table
    function s.SetData(data)
        _ENV.binderData = data
    end

    ---Renders the data
    function s.Render()
        if _ENV.binderData then
            apply(_ENV.binderData, tree)
        end
    end

    return setmetatable(s, Binder)
end

return Binder
