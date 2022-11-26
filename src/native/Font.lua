local rs = require("native/RenderScript").Instance()
local LoadedFont = require("native/LoadedFont")


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

---@class Font
---@field Get fun(name:string, size:integer):LoadedFont
---@field Clear fun()

local Font = {}
Font.__index = Font

local loaded = {} ---@type table<string, LoadedFont>

---Gets the requested font
---@param name FontName
---@param size integer
---@return LoadedFont
function Font.Get(name, size)
    local nameAndSize = string.format("%s%d", name, size)

    local exists = loaded[nameAndSize]
    if not exists then
        loaded[nameAndSize] = LoadedFont.New(name, size)
    end

    return loaded[nameAndSize]
end

---Clears fonts, call this at the end of the screen render.
function Font.Clear()
    for _, value in pairs(loaded) do
        value.Reset()
    end
end

return Font
