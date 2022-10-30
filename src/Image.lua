local rs = require("RenderScript").Instance()
local Vec2 = require("Vec2")

---@module "Props"

---@alias ImageHandle integer

---@class Image
---@field Id ImageHandle
---@field X number
---@field Y number
---@field Props Props
---@field Dimensions Vec2
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
---@param x number
---@param y number
---@param layer Layer
---@param props Props
---@return Image
function Image.New(url, x, y, layer, props)
    local s = {
        Id = rs.LoadImage(url),
        X = x,
        Y = y,
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
        s.X = 0
        s.Y = 0
        s.Dimensions = Vec2.New(rs.GetResolution())
    end

    ---Renders the text
    function s.Render()
        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        rs.AddImage(s.Layer.Id, s.Id, s.X, s.Y, s.Bounds():Unpack())
    end

    return setmetatable(s, Image)
end

return Image
