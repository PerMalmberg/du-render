local BindPath = require("BindPath")
local BindPathTree = require("BindPathTree")
local BinderModifier = require("BinderModifier")
local rs = require("native/RenderScript").Instance()
local Vec2 = require("native/Vec2")

---@class Binder
---@field New fun():Binder
---@field Path fun(path:string, updateInterval?:number):BindPath
---@field MergeData fun(data:table)
---@field Render fun()
---@field Clear fun()
---@field CreateBinding fun(bindExpression:string, targetObject:table, targetProperty:string):boolean
---@field private getByPath fun(sourceObject:table, path:string):any|nil


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
        merge(binderData, data)
    end

    ---Sets the data, discarding any previously merged data.
    ---@param data table
    function s.SetData(data)
        binderData = data or {}
    end

    ---Renders the data
    function s.Render()
        apply(binderData, tree)
    end

    function s.Clear()
        tree = BindPathTree.New()
        binderData = {}
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
    local percentPat = "percent{(.-)}"

    ---@param targetObject table
    ---@param targetProperty string
    ---@param format string
    ---@param initVal any
    local function applyInitValue(targetObject, targetProperty, format, initVal)
        if format then
            targetObject[targetProperty] = string.format(format, initVal)
        else
            targetObject[targetProperty] = initVal
        end
    end

    ---Attempts to create a binding from the expression into the target object
    ---@param bindExpression string
    ---@param targetObject table Object to set properties on
    ---@param targetProperty string Name of property of target object
    ---@return boolean
    function s.CreateBinding(bindExpression, targetObject, targetProperty)
        if not (bindExpression and targetObject and targetProperty) then return false end

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
        path = path or "" -- If left out, binds to the root path
        if not (path and key) then
            rs.Log("'path' or 'key' missing in expression " .. bindExpression)
            return false
        end

        local isMul = bindExpression:match(opMul) ~= nil
        local isDiv = bindExpression:match(opDiv) ~= nil
        local precent = bindExpression:match(percentPat)

        if isVec2 then
            local initVal = Vec2.FromString(init)
            if not initVal then
                rs.Log("Invalid init value '" .. init .. "' for Vec2 in expression" .. bindExpression)
                return false
            end

            local precentVal
            if precent then
                precentVal = Vec2.FromString(precent)
                if not precentVal then
                    rs.Log("Invalid percent value '" .. precent .. "' for Vec2 in expression " .. bindExpression)
                    return false
                end
            end

            -- Vec2 doesn't support format strings
            targetObject[targetProperty] = initVal

            local p = s.Path(path)
            p.Vec2(targetObject, targetProperty, key, interval, BinderModifier.New(isMul, isDiv, precentVal, initVal))

        else
            if isString then
                local p = s.Path(path)
                applyInitValue(targetObject, targetProperty, format, init)
                p.Text(targetObject, targetProperty, key, format or "%s", interval)
            elseif isNum then
                local initVal = tonumber(init)
                if not initVal then
                    rs.Log("Initial value '" .. init .. "' not a number in expression " .. bindExpression)
                    return false
                end

                local precentVal
                if precent then
                    precentVal = tonumber(precent)
                    if not precentVal then
                        rs.Log("Percent value '" .. precent .. "' not a number in expression " .. bindExpression)
                        return false
                    end
                end

                applyInitValue(targetObject, targetProperty, format, initVal)

                local p = s.Path(path)
                p.Number(targetObject, targetProperty, key, format, interval,
                    BinderModifier.New(isMul, isDiv, precentVal, initVal))
            end
        end

        return true
    end

    return setmetatable(s, Binder)
end

---Gets a value at the given path, if the entire path exists, or nil.
---The last part of the path is returned
---@param sourceObject table
---@param path string
---@param desiredType type
---@return number|table|string|nil
function Binder.getByPath(sourceObject, path, desiredType)
    local parts = {}

    for nodeName in string.gmatch(path, "[a-zA-Z_]+") do
        parts[#parts + 1] = nodeName
    end

    if #parts == 0 then return nil end

    local curr = sourceObject

    while #parts > 0 do
        local p = table.remove(parts, 1)
        if type(curr) == "table" and curr[p] then
            curr = curr[p]
        else
            return nil
        end
    end

    if type(curr) ~= desiredType then return nil end

    return curr
end

---Gets a number by path
---@param sourceObject table
---@param path string Path to get value from in the form a/b/c, where c would be the value to get
---@return number|nil
function Binder.GetNumByPath(sourceObject, path)
    local r = Binder.getByPath(sourceObject, path, "number")
    ---@cast r number|nil
    return r
end

---Gets a string by path
---@param sourceObject table
---@param path string Path to get value from in the form a/b/c, where c would be the value to get
---@return string|nil
function Binder.GetStrByPath(sourceObject, path)
    local r = Binder.getByPath(sourceObject, path, "string")
    ---@cast r string|nil
    return r
end

---Gets a table by path
---@param sourceObject table
---@param path string Path to get value from in the form a/b/c, where c would be the value to get
---@return table|nil
function Binder.GetTblByPath(sourceObject, path)
    local r = Binder.getByPath(sourceObject, path, "table")
    ---@cast r table|nil
    return r
end

return Binder
