local BindPath = require("BindPath")
local BindPathTree = require("BindPathTree")

---@class Binder
---@field New fun():Binder
---@field Path fun(path:string, updateInterval?:number):BindPath
---@field MergeData fun(data:table)
---@field Render fun()
---@field Clear fun()


local Binder = {}
Binder.__index = {}

---Creates a new Binder
---@return Binder
function Binder.New()
    local s = {}
    local tree = BindPathTree.New()
    local binderData = {}

    ---Creates a BindPath
    ---@param path string The json-path in the data to the object holding the data to bind to, such as "a/b" or just "" for the root object, Only a-z, A-Z and _ are allowed.
    ---@param updateInterval? number The minimum update interval. Default 0.5.
    ---@return BindPath
    function s.Path(path, updateInterval)
        updateInterval = updateInterval or 0.5
        -- Build a tree for the paths
        local curr = tree
        for nodeName in string.gmatch(path, "[a-zA-Z_]+") do
            if not curr.Sub[nodeName] then
                curr.Sub[nodeName] = BindPathTree.New()
            end
            curr = curr.Sub[nodeName]
        end

        local p = BindPath.New(updateInterval)
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
        if not binderData then
            binderData = {}
        end

        merge(binderData, data)
    end

    ---Sets the data, discarding any previously merged data.
    ---@param data table
    function s.SetData(data)
        binderData = data
    end

    ---Renders the data
    function s.Render()
        if binderData then
            apply(binderData, tree)
        end
    end

    function s.Clear()
        tree = BindPathTree.New()
        binderData = nil
    end

    return setmetatable(s, Binder)
end

return Binder
