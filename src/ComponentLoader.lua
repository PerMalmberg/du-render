local Font  = require("native/Font")
local Props = require("native/Props")
local Vec2  = require("native/Vec2")
local rs    = require("native/RenderScript").Instance()

-- These are Json structures for the layout
---@alias Style PropsTableStruct
---@alias NamedFonts table<string, {font:string, size:FontHandle}>
---@alias NamedStyles table<string,Style>
---@alias BaseCompJson {type:string, layer:integer}
---@alias MouseJson { click: { command:string }, mouse_inside: { set_style:string }}
---@alias Page {components:BaseCompJson[]}
---@alias NamedPages table<string,Page>
---@alias Layout { fonts:NamedFonts, styles:table<string,Props>, pages:table<string, Page> }

---@alias BoxJson {pos:string, dimension:string, corner_radius:number, style:string, mouse:MouseJson}


---@class ComponentLoader
---@field Load fun(layout:Layout):boolean
---@field Styles fun():table<string,Props>
---@field Fonts fun():table<string,FontHandle>
---@field Pages fun():table<string,Page>

local ComponentLoader = {}
ComponentLoader.__index = ComponentLoader

---@param screen Screen
---@param behaviour Behaviour
---@param binder Binder
---@return ComponentLoader
function ComponentLoader.New(screen, behaviour, binder)
    local s = {}

    local fonts = {} ---@type table<string,FontHandle>
    local styles = {} ---@type table<string,Props>
    local pages = {} ---@type NamedPages
    local screenBounds = screen.Bounds()

    ---@param vec2 Vec2
    ---@return Vec2
    local function vec2PercentToPixels(vec2)
        return vec2 / 100 * screen.Bounds()
    end

    local function percentToPixels(num)
        return num / 100 * screenBounds:ComponentMax(screenBounds).x
    end

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

    ---@param layer Layer
    ---@param data BoxJson
    ---@return boolean
    local function createBox(layer, data)
        local pos = Vec2.FromString(data.pos)
        local dim = Vec2.FromString(data.dimension)
        local corner = type(data.corner_radius) == "number" and data.corner_radius or 0

        if not (pos and dim) then rs.Log("Missing pos or dimension for box") return false end
        pos = vec2PercentToPixels(pos)
        dim = vec2PercentToPixels(dim)
        local style = styles[data.style] or Props.Default()

        local box = layer.Box(pos, dim, corner, style)

        behaviour.OnMouseInsideOrOutside(box, function(element, event)
            if event == MouseState.MouseInside and data.mouse and data.mouse.mouse_inside then
                box.Props = style[data.mouse.mouse_inside] or Props.Default()
            else
                box.Props = style
            end
        end)

        behaviour.OnMouseClick(box, function(element, event)
            rs.Log(data.mouse.click.command)
        end)

        return true
    end

    ---Loads the page
    ---@param page Page
    ---@return boolean
    local function loadPage(page)
        if not page.components then return false end
        local res = true
        for _, comp in pairs(page.components) do
            local layer = comp.layer
            local t = comp.type

            if t == "box" and type(layer) == "number" then
                ---@cast comp BoxJson
                res = createBox(screen.Layer(layer), comp)
            end

            if not res then return res end
        end

        return true
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
        return layout ~= nil
            and loadFonts(layout.fonts)
            and loadStyles(layout.styles)
            and loadPages(layout.pages)
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
