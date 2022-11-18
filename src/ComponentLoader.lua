local Font = require("native/Font")
local Props = require("native/Props")

--- QQQ repace with actual classes
---@alias Button {layer:integer, pos:string, dimension:string}
---@alias Gauge table

---@alias Style PropsTableStruct
---@alias NamedFonts table<string, {font:string, size:FontHandle}>
---@alias NamedStyles table<string,Style>
---@alias Page table<string, Button|Gauge>
---@alias NamedPages table<string,Page>
---@alias Layout { fonts:NamedFonts, styles:table<string,Props>, pages:table<string, Page> }


---@class ComponentLoader
---@field Load fun(layout:Layout):boolean
---@field Styles fun():table<string,Props>
---@field Fonts fun():table<string,FontHandle>
---@field Pages fun():table<string,Page>

local ComponentLoader = {}
ComponentLoader.__index = ComponentLoader

---@param screen Screen
---@return ComponentLoader
function ComponentLoader.New(screen)
    local s = {}

    local fonts = {} ---@type table<string,FontHandle>
    local styles = {} ---@type table<string,Props>
    local pages = {} ---@type NamedPages

    ---Loads fonts
    ---@param fontData NamedFonts
    local function loadFonts(fontData)
        if not fontData then return false end
        for name, data in pairs(fontData) do
            fonts[name] = Font.Get(data.font, data.size)
        end

        return true
    end

    ---@param namedStyles NamedStyles
    ---@return boolean
    local function loadStyles(namedStyles)
        if not namedStyles then return false end
        for name, value in pairs(namedStyles) do
            styles[name] = Props.Load(value)
        end

        return true
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
    ---@param page Page
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

    ---Loads the pages
    ---@param pageData NamedPages
    ---@return boolean
    local function loadPages(pageData)
        for name, page in pairs(pageData) do
            local p = loadPage(page)
            if not p then return false end
            pages[name] = page
        end

        return true
    end

    ---Loads controls and data bindings
    ---@param layout Layout The data structure holding the layout
    ---@return boolean
    function s.Load(layout)
        return loadFonts(layout.fonts) and loadStyles(layout.styles) and loadPages(layout.pages)
    end

    ---Gets the syles
    ---@return table<string, Props>
    function s.Styles()
        return styles
    end

    ---Gets the fonts
    ---@return table<string, FontHandle>
    function s.Fonts()
        return fonts
    end

    ---Gets the pages
    ---@return NamedPages
    function s.Pages()
        return pages
    end

    return setmetatable(s, ComponentLoader)
end

return ComponentLoader
