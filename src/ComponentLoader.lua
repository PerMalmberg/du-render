local Font  = require("native/Font")
local Props = require("native/Props")
local Vec2  = require("native/Vec2")
local rs    = require("native/RenderScript").Instance()
local Color = require("native/Color")
local json  = require("dkjson")

-- These are Json structures for the layout
---@alias Style PropsTableStruct
---@alias NamedFonts table<string, {font:string, size:FontHandle}>
---@alias NamedStyles table<string,Style>
---@alias BaseCompJson {type:string, layer:integer}
---@alias MouseJson { click: { command:string }, mouse_inside: { set_style:string }}
---@alias Page {components:BaseCompJson[]}
---@alias NamedPages table<string,Page>
---@alias Layout { fonts:NamedFonts, styles:table<string,Props>, pages:table<string, Page> }

---@alias BoxJson {pos1:string, pos2:string, corner_radius:number, style:string, mouse:MouseJson}

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
---@param stream Stream
---@return ComponentLoader
function ComponentLoader.New(screen, behaviour, binder, stream)
    local s = {}

    local fonts = {} ---@type table<string,FontHandle>
    local styles = {} ---@type table<string,Props>
    local pages = {} ---@type NamedPages
    -- Use a crimson color for missing styles
    local missingStyle = Props.New(Color.New(0.862745098, 0.078431373, 0.235294118))

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
        local corner = type(data.corner_radius) == "number" and data.corner_radius or 0

        local style = styles[data.style] or missingStyle

        local function bindPos(pos, box, prop)
            if not binder.CreateBinding(pos, box, prop) then
                local p = Vec2.FromString(pos)
                if p then
                    box[prop] = p
                else
                    rs.Log("Missing pos1/2 for box")
                    return false
                end
            end
            return true
        end

        local box = layer.Box(Vec2.New(), Vec2.New(), corner, style)

        if not bindPos(data.pos1, box, "Pos1") then
            rs.Log("Error binding/setting Pos1 of box")
            return false
        end

        if not bindPos(data.pos2, box, "Pos2") then
            rs.Log("Error binding/setting Pos2 of box")
            return false
        end

        -- Style when mouse is inside, if any
        local insideStyle ---@type Props|nil

        if data.mouse and data.mouse.mouse_inside then
            local set_style = data.mouse.mouse_inside.set_style
            if set_style then
                insideStyle = styles[set_style] or missingStyle
            end
        end

        behaviour.OnMouseInsideOrOutside(box, function(element, event)
            if event == MouseState.MouseInside and insideStyle then
                box.Props = insideStyle
            else
                box.Props = style
            end
        end)

        if data.mouse and data.mouse.click then
            local cmd = data.mouse.click.command

            if cmd then
                -- Object to hold command for the box
                local cmdContainer = { Command = "" }
                if not binder.CreateBinding(cmd, cmdContainer, "Command") then
                    cmdContainer.Command = cmd
                end

                behaviour.OnMouseClick(box, function(element, event)
                    if cmdContainer.Command ~= "" then
                        stream.Write(json.encode({ mouse_click = cmdContainer.Command }))
                    end
                end)
            end
        end

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
        screen.Clear()
        behaviour.Clear()
        binder.Clear()

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
