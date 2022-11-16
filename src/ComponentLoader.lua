local Font = require("Font")
local Props = require("Props")


---@alias Button {layer:integer, pos:string, dimension:string}
---@alias Gauge table

---@alias Style PropsTableStruct
---@alias Fonts table<string, {font:string, size:integer}>
---@alias Page table<string, Button|Gauge>
---@alias Layout { fonts:Fonts, styles:table<string,Props>, pages:table<string, Page> }


---@class ComponentLoader
---@field Load fun(layout:Layout):boolean
---@field Styles fun():table<string,Props>

local ComponentLoader = {}
ComponentLoader.__index = ComponentLoader

---@param screen Screen
---@return ComponentLoader
function ComponentLoader.New(screen)
    local s = {}

    local fonts = {} ---@type table<string,integer>
    local styles = {} ---@type table<string,Props>

    ---Loads fonts
    ---@param fontData table<string, {font:string, size:integer}>
    local function loadFonts(fontData)
        if not fontData then return end
        for name, data in pairs(fontData) do
            fonts[name] = Font.Get(data.font, data.size)
        end
    end

    ---@param namedStyles table<string,Style>
    local function loadStyles(namedStyles)
        if not namedStyles then return end
        for name, value in pairs(namedStyles) do
            styles[name] = Props.Load(value)
        end
    end

    ---@param props table<string,any>
    ---@return boolean
    local function createButton(props)
        local res = true
        if not props.layer then return false end



        return res
    end

    ---@param props table<string,any>
    ---@return boolean
    local function createGauge(props)
        local res = true

        return res
    end

    ---Loads the page
    ---@param page table<string, table>
    ---@return boolean
    local function loadPage(page)
        local res = true
        for controlType, props in pairs(page) do
            if controlType == "button" then res = createButton(props)
            elseif controlType == "gauge" then res = createGauge(props) end

            if not res then return res end
        end

        return res
    end

    ---Loads controls and data bindings
    ---@param layout Layout The data structure holding the layout
    ---@return boolean
    function s.Load(layout)
        loadFonts(layout.fonts)
        loadStyles(layout.styles)

        --[[ local page = layout[pageName]
        if page then
            return loadPage(page)
        end ]]

        return false
    end

    ---Gets the syles
    ---@return table<string, Props>
    function s.Styles()
        return styles
    end

    return setmetatable(s, ComponentLoader)
end

return ComponentLoader
