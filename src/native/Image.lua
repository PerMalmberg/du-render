local rs = require("native/RenderScript").Instance()
local Vec2 = require("native/Vec2")

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
---@field Hit fun(point:Vec2):boolean

local Image = {}
Image.__index = Image

---Creates a new Image
---@param url string
---@param pos Vec2
---@param dimensions Vec2
---@param layer Layer
---@param props Props
---@return Image
function Image.New(url, pos, dimensions, layer, props)
    local s = {
        Id = rs.LoadImage(url),
        Pos = pos,
        Dimensions = dimensions,
        Props = props,
        Layer = layer
    }

    ---Returns true if the image is loaded
    ---@return boolean
    function s.IsLoaded()
        return rs.IsImageLoaded(s.Id)
    end

    ---Width of image
    ---@return number
    function s.Width()
        return s.Dimensions.x
    end

    ---Width of image
    ---@return number
    function s.Height()
        return s.Dimensions.y
    end

    function s.FillScreen()
        s.Pos = Vec2.New()
        s.Dimensions = Vec2.New(rs.GetResolution())
    end

    ---Renders the text
    function s.Render()
        local loaded = rs.IsImageLoaded(s.Id)
        if loaded and s.Dimensions == Vec2.New() then
            -- Set default size if not already set
            s.Dimensions = Vec2.New(rs.GetImageSize(s.Id))
        end

        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        rs.AddImage(s.Layer.Id, s.Id, s.Pos.x, s.Pos.y, s.Dimensions:Unpack())
    end

    --Determines if the position is within the element
    ---@param point Vec2
    ---@return boolean
    function s.Hit(point)
        local max = s.Pos + s.Dimensions
        return point.x >= s.Pos.x and point.x <= max.x
            and point.y >= s.Pos.y and point.y <= max.y
    end

    return setmetatable(s, Image)
end

return Image
