---@class TextAlign
---@field Hor RSAlignHor
---@field Ver RSAlignVer

local TextAlign = {}
TextAlign.__index = TextAlign

---Creates a new Shadow
---@param horizontal RSAlignHor
---@param vertical RSAlignVer
function TextAlign.New(horizontal, vertical)
    local s = {
        Hor = horizontal,
        Ver = vertical
    }

    return setmetatable(s, TextAlign)
end

function TextAlign.Default()
    return TextAlign.New(RSAlignHor.Left, RSAlignVer.Bottom)
end

return TextAlign
