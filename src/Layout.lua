local Font             = require("native/Font")
local Props            = require("native/Props")
local Vec2             = require("native/Vec2")
local rs               = require("native/RenderScript").Instance()
local Color            = require("native/Color")
local json             = require("dkjson")
local Binder           = require("Binder")
local ColorAndDistance = require("native/ColorAndDistance")

-- These are Json structures for the layout
---@alias Style PropsTableStruct
---@alias NamedFonts table<string, {font:string, size:FontHandle}>
---@alias NamedStyles table<string,Style>
---@alias BaseCompJson {type:string, layer:integer}
---@alias MouseJson { click: { command:string }, mouse_inside: { set_style:string }}
---@alias PageJson {components:BaseCompJson[]}
---@alias NamedPagesJson table<string,PageJson>
---@alias LayoutJson { fonts:NamedFonts, styles:table<string,Props>, pages:table<string, PageJson> }

---@alias BoxJson {pos1:string, pos2:string, corner_radius:number, style:string, mouse:MouseJson}
---@alias TextJson {pos1:string, style:string, font:string, text:string, mouse:MouseJson}
---@alias LineJson {pos1:string, pos2:string, style:string, mouse:MouseJson, mouse:MouseJson}
---@alias CircleJson {pos1:string, radius:number, style:string, mouse:MouseJson, mouse:MouseJson}

---@alias Page Layer[]
---@alias Pages table<string,Page>

---@class Layout
---@field SetLayout fun(layout:Layout):boolean
---@field Styles fun():table<string,Props>
---@field Fonts fun():table<string,FontHandle>
---@field Activate fun(page:string):boolean

local Layout = {}
Layout.__index = Layout

---@param screen Screen
---@param behaviour Behaviour
---@param binder Binder
---@param stream Stream
---@return Layout
function Layout.New(screen, behaviour, binder, stream)
    local s = {}

    local fonts = {} ---@type table<string,LoadedFont>
    local styles = {} ---@type table<string,Props>
    local layoutData = {} ---@type LayoutJson
    -- Use a crimson color for missing styles
    local crimson = Color.New(0.862745098, 0.078431373, 0.235294118)
    local missingStyle = Props.New(crimson, 0, ColorAndDistance.New(Color.Transparent(), 0),
        ColorAndDistance.New(crimson, 1))
    local missingFont = Font.Get(FontName.RobotoMono, 10)

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

    ---@param pos string
    ---@param object Box|Line|Text|Circle
    ---@param prop string
    ---@param componentType string
    ---@return boolean
    local function bindPos(pos, object, prop, componentType)
        if not binder.CreateBinding(pos, object, prop) then
            local p = Vec2.FromString(pos)
            if p then
                object[prop] = p
            else
                rs.Log("Invalid value for Vec2 for " .. prop .. " in " .. componentType .. " '" .. tostring(pos) .. "'")
                return false
            end
        end
        return true
    end

    ---Binds mouse actions
    ---@param object Text|Box|Line|Circle
    ---@param baseStyle Style
    ---@param data BoxJson|TextJson|LineJson|CircleJson
    local function bindMouse(object, baseStyle, data)
        local bindData = {
            ---@type Props|nil
            baseStyle = baseStyle,
            ---@type Props|nil
            insideStyle = nil,
            ---@type string|nil
            clickCommand = nil
        }

        local inside = Binder.GetStrByPath(data, "mouse/inside/set_style")
        if inside then
            bindData.insideStyle = styles[inside] or missingStyle
        end

        behaviour.OnMouseInsideOrOutside(object, function(element, event)
            if event == MouseState.MouseInside and bindData.insideStyle then
                object.Props = bindData.insideStyle
            else
                object.Props = bindData.baseStyle
            end
        end)

        local cmd = Binder.GetStrByPath(data, "mouse/click/command")

        if cmd then
            if not binder.CreateBinding(cmd, bindData, "clickCommand") then
                bindData.clickCommand = cmd
            end

            behaviour.OnMouseClick(object, function(element, event)
                local c = bindData.clickCommand
                if c ~= nil and string.len(c) > 0 then
                    stream.Write(json.encode({ mouse_click = c }))
                end
            end)
        end
    end

    ---@param layer Layer
    ---@param data BoxJson
    ---@return boolean
    local function createBox(layer, data)
        local corner = Binder.GetNumByPath(data, "corner_radius") or 0

        local style = styles[Binder.GetStrByPath(data, "style") or "-"] or missingStyle

        local box = layer.Box(Vec2.New(), Vec2.New(), corner, style)

        if not (bindPos(data.pos1, box, "Pos1", "box")
            and bindPos(data.pos2, box, "Pos2", "box")) then
            return false
        end

        bindMouse(box, style, data)

        return true
    end

    ---@param layer Layer
    ---@param data TextJson
    ---@return boolean
    local function createText(layer, data)
        local style = styles[Binder.GetStrByPath(data, "style") or "-"] or missingStyle

        local fontName = Binder.GetStrByPath(data, "font") or "-"
        local textFont = fonts[fontName] or missingFont

        local text = layer.Text("", Vec2.New(), textFont, style)

        if not bindPos(data.pos1, text, "Pos1", "text") then
            return false
        end

        if not binder.CreateBinding(data.text, text, "Text") then
            text.Text = data.text
        end

        bindMouse(text, style, data)

        return true
    end

    ---@param layer Layer
    ---@param data LineJson
    local function createLine(layer, data)
        local style = styles[Binder.GetStrByPath(data, "style") or "-"] or missingStyle

        local line = layer.Line(Vec2.New(), Vec2.New(), style)

        if not (bindPos(data.pos1, line, "Pos1", "line")
            and bindPos(data.pos2, line, "Pos2", "line")) then
            return false
        end

        bindMouse(line, style, data)

        return true
    end

    ---@param layer Layer
    ---@param data LineJson
    local function createCircle(layer, data)
        local radius = Binder.GetNumByPath(data, "radius") or 50
        local style = styles[Binder.GetStrByPath(data, "style") or "-"] or missingStyle

        local circle = layer.Circle(Vec2.New(), radius, style)

        if not bindPos(data.pos1, circle, "Pos1", "circle") then
            return false
        end

        bindMouse(circle, style, data)

        return true
    end

    ---Loads the page
    ---@param page PageJson
    ---@return boolean
    local function loadPage(page)
        if not page.components then return false end
        local res = true
        for _, comp in pairs(page.components) do
            local layer = comp.layer
            local t = comp.type

            if type(layer) == "number" then
                local l = screen.Layer(layer)
                if t == "box" then
                    ---@cast comp BoxJson
                    res = createBox(l, comp)
                elseif t == "text" then
                    ---@cast comp TextJson
                    res = createText(l, comp)
                elseif t == "line" then
                    ---@cast comp LineJson
                    res = createLine(l, comp)
                elseif t == "circle" then
                    ---@cast comp CircleJson
                    res = createCircle(l, comp)
                end
            end

            if not res then return res end
        end

        return true
    end

    ---Sets the layout and loads fonts and styles
    ---@param layout LayoutJson
    ---@return boolean
    function s.SetLayout(layout)
        layoutData = layout
        return loadFonts(layoutData.fonts) and loadStyles(layoutData.styles)
    end

    ---Loads controls and data bindings
    ---@param pageName string The page name to activate
    ---@return boolean
    function s.Activate(pageName)
        screen.Clear()
        behaviour.Clear()
        binder.Clear()

        local pages = layoutData.pages

        if pages then
            local p = pages[pageName]

            if p then
                return loadPage(p)
            end
        end

        return false
    end

    ---Gets the syles
    ---@return table<string, Props>
    function s.Styles()
        return styles
    end

    ---Gets the fonts
    ---@return table<string, LoadedFont>
    function s.Fonts()
        return fonts
    end

    return setmetatable(s, Layout)
end

return Layout
