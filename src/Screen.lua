local rs = require("RenderScript").Instance()
local Layer = require("Layer")

---@class Screen
---@field Instance fun():Screen
---@field Layer fun():Layer
---@field Add fun(c:table)
---@field Render fun(frames:integer)

local Screen = {}
Screen.__index = Screen

local singelton

function Screen.Instance()
    if singelton then
        return singelton
    end

    local s = {}
    local layers = {} ---@type Layer[]
    local components = {} ---@type table[]

    ---Gets the layer with the given id
    ---@param id integer
    ---@return Layer
    function s.Layer(id)
        while id > #layers do
            table.insert(layers, Layer.New(s))
        end

        return layers[id]
    end

    function s.Add(comp)
        table.insert(components, comp)
    end

    ---Renders the screen content
    ---@param frames integer
    function s.Render(frames)
        for i = 1, #components do
            components[i].Render()
        end

        rs.RequestAnimationFrame(frames)
    end

    singelton = setmetatable(s, Screen)
    return singelton
end

return Screen
