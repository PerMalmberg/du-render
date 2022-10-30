local rs = require("RenderScript").Instance()
local Vec2 = require("Vec2")

---@module "Props"

---@alias ImageHandle integer

---@class Image
---@field Id ImageHandle
---@field Pos Vec2
---@field Dimensions Vec2
---@field Props Props
---@field FillScreen fun()
---@field IsLoaded fun():boolean
---@field Bounds fun():Vec2
---@field Width fun():number
---@field Height fun():number
---@field Render fun()

local Image = {}
Image.__index = Image

---Creates a new Image
---@param url string
---@param pos Vec2
---@param layer Layer
---@param props Props
---@return Image
function Image.New(url, pos, layer, props)
    local s = {
        Id = rs.LoadImage(url),
        Pos = pos,
        Dimensions = Vec2.New(rs.GetResolution()),
        Props = props,
        Layer = layer
    }

    ---Returns true if the image is loaded
    ---@return boolean
    function s.IsLoaded()
        return rs.IsImageLoaded(s.Id)
    end

    ---Returns the width and height, in pixels the image occupies.
    ---@return Vec2
    function s.Bounds()
        return s.Dimensions
    end

    ---Width of image
    ---@return number
    function s.Width()
        return s.Bounds().x
    end

    ---Width of image
    ---@return number
    function s.Height()
        return s.Bounds().y
    end

    function s.FillScreen()
        s.Pos = Vec2.New()
        s.Dimensions = Vec2.New(rs.GetResolution())
    end

    ---Renders the text
    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        rs.AddImage(s.Layer.Id, s.Id, s.Pos.x, s.Pos.y, s.Dimensions:Unpack())
    end

    return setmetatable(s, Image)
end

return Image
