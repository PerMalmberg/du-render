local rs = require("native/RenderScript").Instance()

---@class Font
---@field Size number
---@field Name string

---@alias FontHandle integer

---@enum FontName
FontName = {
    FiraMono                = "FiraMono",
    FiraMonoBold            = "FiraMono-Bold",
    Montserrat              = "Montserrat",
    MontserratLight         = "Montserrat-Light",
    MontserratBold          = "Montserrat-Bold",
    Play                    = "Play",
    PlayBold                = "Play-Bold ",
    RefrigeratorDeluxe      = "RefrigeratorDeluxe",
    RefrigeratorDeluxeLight = "RefrigeratorDeluxe-Light",
    RobotoCondensed         = "RobotoCondensed",
    RobotoMono              = "RobotoMono",
    RobotoMonoBold          = "RobotoMono-Bold",
}

local Font = {}
Font.__index = Font

---Gets the requested font
---@param name FontName
---@param size integer
---@return FontHandle
function Font.Get(name, size)
    return rs.LoadFont(name, size)
end

return Font
