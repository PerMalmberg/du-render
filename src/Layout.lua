local Font             = require("native/Font")
local Props            = require("native/Props")
local Vec2             = require("native/Vec2")
local rs               = require("native/RenderScript").Instance()
local Color            = require("native/Color")
local Binder           = require("Binder")
local ColorAndDistance = require("native/ColorAndDistance")
local DeepCopy         = require("DeepCopy")

-- These are Lua structures for the layout
---@alias Style PropsTableStruct
---@alias NamedFonts table<string, {font:string, size:FontHandle}>
---@alias NamedStyles table<string,Style>
---@alias ReplicateStruct {x_step:number, y_step:number, x_count:integer, y_count:number}
---@alias StringOrBool string|boolean
---@alias BaseCompStruct {type:string, layer:integer, hitable:StringOrBool, replicate:ReplicateStruct}
---@alias MouseStruct { click: { command:string }, inside: { set_style:string }}
---@alias PageStruct {components:BaseCompStruct[]}
---@alias NamedPagesStruct table<string,PageStruct>
---@alias LayoutStruct { fonts:NamedFonts, styles:table<string,Props>, pages:table<string, PageStruct> }

---@alias BoxStruct {pos1:string, pos2:string, corner_radius:number, style:string, mouse:MouseStruct, type:string, layer:integer, visible:StringOrBool, hitable:StringOrBool, replicate:ReplicateStruct}
---@alias TextStruct {pos1:string, style:string, font:string, text:string, mouse:MouseStruct, type:string, layer:integer, visible:StringOrBool, hitable:StringOrBool, replicate:ReplicateStruct}
---@alias LineStruct {pos1:string, pos2:string, style:string, mouse:MouseStruct, mouse:MouseStruct, type:string, layer:integer, visible:StringOrBool, hitable:StringOrBool, replicate:ReplicateStruct}
---@alias CircleStruct {pos1:string, radius:number, style:string, mouse:MouseStruct, mouse:MouseStruct, type:string, layer:integer, visible:StringOrBool, hitable:StringOrBool, replicate:ReplicateStruct}
---@alias ImageStruct {pos1:string, dimensions:string, sub:string, subDimensions:string, url:string, mouse:MouseStruct, type:string, layer:integer, visible:StringOrBool, hitable:StringOrBool, replicate:ReplicateStruct}

---@alias Page Layer[]
---@alias Pages table<string,Page>

---@class Layout
---@field SetLayout fun(layout:LayoutStruct):boolean
---@field Styles fun():table<string,Props>
---@field Fonts fun():table<string,FontHandle>
---@field Activate fun(page:string):boolean

local Layout           = {}
Layout.__index         = Layout

---@param screen Screen
---@param behaviour Behaviour
---@param binder Binder
---@param stream Stream
---@return Layout
function Layout.New(screen, behaviour, binder, stream)
    local s = {}

    local fonts = {} ---@type table<string,LoadedFont>
    local styles = {} ---@type table<string,Props>
    local layoutData = {} ---@type LayoutStruct
    -- Use a crimson color for missing styles
    local crimson = Color.New(0.862745098, 0.078431373, 0.235294118)
    local missingStyle = Props.New(crimson, 0, ColorAndDistance.New(Color.Transparent(), 0),
        ColorAndDistance.New(crimson, 1))
    local missingFont = Font.Get(FontName.RobotoMono, 10)
    local activatePagePat = "activatepage{%s*(.-)%s*}"

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
    ---@param object Box|Line|Text|Circle|Image
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
    ---@param object Text|Box|Line|Circle|Image
    ---@param data BoxStruct|TextStruct|LineStruct|CircleStruct|ImageStruct
    local function bindStyles(object, data)
        local bindData = {
            ---@type string
            style = "",
            ---@type string|nil
            insideStyle = nil,
            ---@type string|nil
            clickCommand = nil
        }

        local style = Binder.GetStrByPath(data, "style") or "-"
        if not binder.CreateBinding(style, bindData, "style") then
            -- Assume style is just a style name
            bindData.style = style
        end

        local insideStyle = Binder.GetStrByPath(data, "mouse/inside/set_style")
        if insideStyle then
            if not binder.CreateBinding(insideStyle, bindData, "insideStyle") then
                -- Assume style is just a name
                bindData.insideStyle = insideStyle
            end
        end

        behaviour.OnMouseInsideOrOutside(object, function(element, event)
            if event == MouseState.MouseInside and bindData.insideStyle then
                object.Props = styles[bindData.insideStyle] or missingStyle
            else
                object.Props = styles[bindData.style] or missingStyle
            end
        end)
    end

    ---Binds mouse actions
    ---@param object Text|Box|Line|Circle|Image
    ---@param data BoxStruct|TextStruct|LineStruct|CircleStruct|ImageStruct
    local function bindClick(object, data)
        local bindData = {
            ---@type string|nil
            clickCommand = nil
        }

        local cmd = Binder.GetStrByPath(data, "mouse/click/command")

        if cmd then
            if not binder.CreateBinding(cmd, bindData, "clickCommand") then
                bindData.clickCommand = cmd
            end

            behaviour.OnMouseClick(object, function(element, event)
                local c = bindData.clickCommand
                if c ~= nil and string.len(c) > 0 then
                    local page = c:match(activatePagePat)
                    if page then
                        s.Activate(page)
                    else
                        stream.Write({ mouse_click = c })
                    end
                end
            end)
        end
    end

    ---@param object Text|Box|Line|Circle|Image
    ---@param data BoxStruct|TextStruct|LineStruct|CircleStruct|ImageStruct
    local function bindVisibility(object, data)
        local t = type(data.visible)
        if t == "boolean" then
            local b = data.visible
            ---@cast b boolean
            object.Visible = b
        elseif t == "string" then
            local b = data.visible
            ---@cast b string
            if not binder.CreateBinding(b, object, "Visible") then
                return false
            end
        elseif t ~= "nil" then
            rs.Log("Invalid data type for visibility binding: " .. t)
            return false
        end
        return true
    end

    ---@param object Text|Box|Line|Circle|Image
    ---@param data BoxStruct|TextStruct|LineStruct|CircleStruct|ImageStruct
    local function bindHitable(object, data)
        local t = type(data.hitable)
        if t == "boolean" then
            local b = data.hitable
            ---@cast b boolean
            object.Hitable = b
        elseif t == "string" then
            local b = data.hitable
            ---@cast b string
            if not binder.CreateBinding(b, object, "Hitable") then
                return false
            end
        elseif t ~= "nil" then
            rs.Log("Invalid data type for hitable binding: " .. t)
            return false
        end
        return true
    end

    ---@param object Text|Box|Line|Circle|Image
    ---@param data BoxStruct|TextStruct|LineStruct|CircleStruct|ImageStruct
    local function applyBindings(object, data)
        bindStyles(object, data)
        bindClick(object, data)
        bindVisibility(object, data)
        bindHitable(object, data)
    end

    ---@param layer Layer
    ---@param data BoxStruct
    ---@return Box|nil
    local function createBox(layer, data)
        local corner = Binder.GetNumByPath(data, "corner_radius") or 0

        local box = layer.Box(Vec2.New(), Vec2.New(), corner)

        if not (bindPos(data.pos1, box, "Pos1", "box")
                and bindPos(data.pos2, box, "Pos2", "box")) then
            return nil
        end

        applyBindings(box, data)

        return box
    end

    ---@param layer Layer
    ---@param data TextStruct
    ---@return Text|nil
    local function createText(layer, data)
        local fontName = Binder.GetStrByPath(data, "font") or "-"
        local textFont = fonts[fontName] or missingFont

        local text = layer.Text("", Vec2.New(), textFont)

        if not bindPos(data.pos1, text, "Pos1", "text") then
            return nil
        end

        if not binder.CreateBinding(data.text, text, "Text") then
            text.Text = data.text
        end

        applyBindings(text, data)

        return text
    end

    ---@param layer Layer
    ---@param data LineStruct
    ---@return Line|nil
    local function createLine(layer, data)
        local line = layer.Line(Vec2.New(), Vec2.New())

        if not (bindPos(data.pos1, line, "Pos1", "line")
                and bindPos(data.pos2, line, "Pos2", "line")) then
            return nil
        end

        applyBindings(line, data)

        return line
    end

    ---@param layer Layer
    ---@param data CircleStruct
    ---@return Circle|nil
    local function createCircle(layer, data)
        local radius = Binder.GetNumByPath(data, "radius") or 50

        local circle = layer.Circle(Vec2.New(), radius)

        if not bindPos(data.pos1, circle, "Pos1", "circle") then
            return nil
        end

        applyBindings(circle, data)
        return circle
    end

    ---@param layer Layer
    ---@param data ImageStruct
    ---@return Image|nil
    local function createImage(layer, data)
        local url = Binder.GetStrByPath(data, "url")

        local image = layer.Image(url or "", Vec2.zero, Vec2.zero)

        if not (bindPos(data.pos1, image, "Pos", "image") and
                bindPos(data.dimensions or tostring(Vec2.zero), image, "Dimensions", "image")) then
            return nil
        end

        if data.sub and data.subDimensions then
            if not (bindPos(data.sub, image, "Sub", "image") and bindPos(data.subDimensions, image, "SubDimensions", "image")) then
                return nil
            end
        end

        applyBindings(image, data)
        return image
    end

    ---@param comp BaseCompStruct
    ---@return boolean
    local function createComponent(comp)
        local res = nil ---@type Box|Circle|Line|Image|Text|nil
        local layer = comp.layer
        local t = tostring(comp.type)

        if type(layer) == "number" then
            local l = screen.Layer(layer)
            if t == "box" then
                ---@cast comp BoxStruct
                res = createBox(l, comp)
            elseif t == "text" then
                ---@cast comp TextStruct
                res = createText(l, comp)
            elseif t == "line" then
                ---@cast comp LineStruct
                res = createLine(l, comp)
            elseif t == "circle" then
                ---@cast comp CircleStruct
                res = createCircle(l, comp)
            elseif t == "image" then
                ---@cast comp ImageStruct
                res = createImage(l, comp)
            end
        else
            rs.Log("Invalid layer number '" .. tostring(layer) .. "', type " .. t)
        end

        if res == nil then
            rs.Log("Could not create component for type " .. t)
        end

        return res ~= nil
    end

    ---@param c table
    ---@param count integer
    local function replaceReplicationCount(c, count)
        for key, value in pairs(c) do
            ---@cast key string
            if type(value) == "table" then
                replaceReplicationCount(value, count)
            elseif type(value) == "string" then
                ---@cast value string
                c[key] = value:gsub("%[%#%]", tostring(count))
            end
        end
    end

    ---@param comp table
    ---@param addX number
    ---@param addY number
    ---@param count integer
    local function applyReplication(comp, addX, addY, count)
        local i = 1

        ---@param v Vec2
        ---@return string
        local function addToVec(v)
            return (v + Vec2.New(addX, addY)):ToString()
        end

        while true do
            local name = string.format("pos%d", i)
            i = i + 1

            ---@type string|nil
            local val = comp[name]
            if not val then
                break
            end

            local p = Vec2.FromString(val)

            if p then
                comp[name] = addToVec(p)
            else
                local init = val:match(Binder.InitPat)
                if init then
                    p = Vec2.FromString(init)
                    if p then
                        val = val:gsub("init{%(.-%)}", "init{" .. addToVec(p) .. "}")
                    end
                end

                local percent = val:match(Binder.PercentPat)
                if percent then
                    p = Vec2.FromString(percent)
                    if p then
                        val = val:gsub("percent{%(.-%)}", "percent{" .. addToVec(p) .. "}")
                    end
                end

                comp[name] = val
            end
        end

        replaceReplicationCount(comp, count)
    end

    ---Loads the page
    ---@param page PageStruct
    ---@return boolean
    local function loadPage(page)
        if not page.components then
            rs.Log("No components in page")
            return false
        end

        local res = true
        for _, comp in pairs(page.components) do
            local rep = comp.replicate or {}
            local addX = 0
            local addY = 0
            local count = 1

            -- Replicate components row by row
            for y = 1, rep.y_count or 1, 1 do
                for x = 1, rep.x_count or 1 do
                    local compCopy = DeepCopy(comp)
                    applyReplication(compCopy, addX, addY, count)
                    res = createComponent(compCopy)
                    if not res then break end

                    addX = addX + (rep.x_step or 0)
                    count = count + 1
                end

                addY = addY + (rep.y_step or 0)
                addX = 0
            end
            if not res then return res end
        end

        return true
    end

    ---Sets the layout and loads fonts and styles
    ---@param layout LayoutStruct
    ---@return boolean
    function s.SetLayout(layout)
        layoutData = layout
        return loadFonts(layoutData.fonts) and loadStyles(layoutData.styles)
    end

    local function split(str, separator)
        local sep, fields = separator or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c) fields[#fields + 1] = c end)
        return fields
    end

    ---Loads controls and data bindings
    ---@param pageNames string The page name to activate. Comma separated list of pages to be shown at the same time
    ---@return boolean
    function s.Activate(pageNames)
        screen.Clear()
        behaviour.Clear()
        binder.Clear()

        local pages = layoutData.pages

        if pages then
            for _, name in ipairs(split(pageNames, ",")) do
                local p = pages[name]

                if not p or not loadPage(p) then
                    rs.Log("Could not load page by name '" .. name .. "'")
                    return false
                end
            end
        else
            rs.Log("No pages in layout")
        end

        return true
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
