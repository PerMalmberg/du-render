local rs = require("RenderScript").Instance()

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

local loaded = {} ---@type table<string,FontHandle>

---Gets the requested font
---@param name FontName
---@param size integer
---@return FontHandle
function Font.Get(name, size)
    local key = string.format("%s%f", name, size)
    local f = loaded[key]

    if not f then
        f = rs.LoadFont(name, size)
        loaded[key] = f
    end

    return f
end

return Font
