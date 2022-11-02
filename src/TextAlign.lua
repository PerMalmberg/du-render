---@class TextAlign
---@field Hor RSAlignHor
---@field Ver RSAlignVer
---@field Default fun():TextAlign

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

---Creates a default text alignment
---@return TextAlign
function TextAlign.Default()
    return TextAlign.New(RSAlignHor.Left, RSAlignVer.Top)
end

return TextAlign
