local rs = require("native/RenderScript").Instance()
local Vec2 = require("native/Vec2")

---@module "Props"

---@alias ImageHandle integer

---@class Image
---@field Id ImageHandle
---@field Pos Vec2
---@field Dimensions Vec2
---@field Sub Vec2
---@field SubDimensions Vec2
---@field Props Props
---@field FillScreen fun()
---@field IsLoaded fun():boolean
---@field Bounds fun():Vec2
---@field Width fun():number
---@field Height fun():number
---@field Render fun()
---@field Hit fun(point:Vec2):boolean
---@field Visible boolean
---@field Hitable boolean

local Image = {}
Image.__index = Image

---Creates a new Image
---@param url string
---@param pos Vec2
---@param dimensions Vec2
---@param layer Layer
---@param props Props
---@param sub? Vec2
---@param subDimensions? Vec2
---@return Image
function Image.New(url, pos, dimensions, layer, props, sub, subDimensions)
    local s = {
        Pos = pos,
        Dimensions = dimensions,
        Sub = sub,
        SubDimensions = subDimensions,
        Props = props,
        Layer = layer,
        Visible = true,
        Hitable = true
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
        local id = rs.LoadImage(url)
        local loaded = rs.IsImageLoaded(id)

        if loaded and s.Dimensions == Vec2.zero then
            -- Set default size if not already set
            s.Dimensions = Vec2.New(rs.GetImageSize(id))
        end

        local layerId = s.Layer.Id
        s.Props.Apply(layerId)
        if s.Sub and s.SubDimensions then
            rs.AddImageSub(s.Layer.Id, id, s.Pos.x, s.Pos.y, s.Dimensions.x, s.Dimensions.y, s.Sub.x, s.Sub.y,
                s.SubDimensions.x, s.SubDimensions.y)
        else
            rs.AddImage(s.Layer.Id, id, s.Pos.x, s.Pos.y, s.Dimensions.x, s.Dimensions.y)
        end
    end

    --Determines if the position is within the element
    ---@param point Vec2
    ---@return boolean
    function s.Hit(point)
        local max = s.Pos + s.Dimensions
        return s.Hitable and s.Visible and point.x >= s.Pos.x and point.x <= max.x
            and point.y >= s.Pos.y and point.y <= max.y
    end

    return setmetatable(s, Image)
end

return Image
