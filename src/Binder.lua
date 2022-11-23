local BindPath = require("BindPath")
local BindPathTree = require("BindPathTree")
local rs = require("native/RenderScript").Instance()
local Vec2 = require("native/Vec2")

---@class Binder
---@field New fun():Binder
---@field Path fun(path:string, updateInterval?:number):BindPath
---@field MergeData fun(data:table)
---@field Render fun()
---@field Clear fun()
---@field CreateBinding fun(bindExpression:string, targetObject:table, targetProperty:string):boolean


local Binder = {}
Binder.__index = {}
local DEFAULT_UPDATE_INTERVAL = 0.5

---Creates a new Binder
---@return Binder
function Binder.New()
    local s = {}
    local tree = BindPathTree.New()
    local binderData = {}

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

        local p = BindPath.New(DEFAULT_UPDATE_INTERVAL)
        table.insert(curr.Bind, p)
        return p
    end

    ---@param data table
    ---@param branch BindPathTree
    local function apply(data, branch)
        -- Iterate each key in the data
        for key, value in pairs(data) do
            local t = type(value)
            if Vec2.IsVec2(value) then
                for _, bind in pairs(branch.Bind) do
                    bind.ProcessVec2(key, Vec2.New(value))
                end
            elseif t == "table" then
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
                -- Multi-values, such as Vec2 are handled by this too.
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

    local stringPat = "$str%((.-)%)"
    local numPat = "$num%((.-)%)"
    local vec2Pat = "$vec2%((.-)%)"
    local pathPat = "path{([^%s:{}]-):([^%s:{}]-)}"
    local formatPat = "format{([%s%S]-)}"
    local intervalPat = "interval{(%d*%.?%d+)}"
    local initPat = "init{(.-)}"
    local opMul = "op{mul}"
    local opDiv = "op{div}"

    ---Attempts to create a binding from the expression into the target object
    ---@param bindExpression string
    ---@param targetObject table Object to set properties on
    ---@param targetProperty string Name of property of target object
    ---@return boolean
    function s.CreateBinding(bindExpression, targetObject, targetProperty)
        if not (bindExpression and targetObject) then return false end

        local isString = bindExpression:match(stringPat) ~= nil
        local isNum = not isString and bindExpression:match(numPat) ~= nil
        local isVec2 = not isNum and bindExpression:match(vec2Pat) ~= nil

        if not (isString or isNum or isVec2) then
            return false
        end

        local format = bindExpression:match(formatPat)
        local interval = tonumber(bindExpression:match(intervalPat)) or DEFAULT_UPDATE_INTERVAL
        local init = bindExpression:match(initPat)

        if not init then
            rs.Log("'init' missing in expression " .. bindExpression)
            return false
        end

        local path, key = bindExpression:match(pathPat)
        if not (path and key) then
            rs.Log("'path' or 'key' missing in expression " .. bindExpression)
            return false
        end

        local isMul = bindExpression:match(opMul) ~= nil
        local isDiv = bindExpression:match(opDiv) ~= nil

        if isVec2 then
            local initVal = Vec2.FromString(init)
            if not initVal then
                rs.Log("Invalid init value '" .. init .. "' for Vec2 in expression" .. bindExpression)
                return false
            end

            targetObject[targetProperty] = initVal

            local p = s.Path(path)
            p.Vec2(targetObject, targetProperty, key, interval, function(v)
                if isMul then
                    return initVal * v
                elseif isDiv then
                    if v.x ~= 0 and v.y ~= 0 then
                        return initVal / v
                    end
                end

                return v
            end)

        else
            if isString then
                local p = s.Path(path)
                targetObject[targetProperty] = init
                p.Text(targetObject, targetProperty, key, format or "%s", interval)
            elseif isNum then
                local initVal = tonumber(init)
                if not initVal then
                    rs.Log("Initial value '" .. init .. "' not a number in expression " .. bindExpression)
                    return false
                end

                targetObject[targetProperty] = initVal

                local p = s.Path(path)
                p.Number(targetObject, targetProperty, key, format, interval, function(n)
                    if isMul then return initVal * n
                    elseif isDiv and n ~= 0 then return initVal / n
                    else return n end
                end)
            end
        end

        return true
    end

    return setmetatable(s, Binder)
end

return Binder
