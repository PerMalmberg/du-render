---@enum RSAlignHor
RSAlignHor = {
    Left = 0,
    Center = 1,
    Right = 2,
}

---@enum RSAlignVer
RSAlignVer = {
    Ascender = 0,
    Top = 1,
    Middle = 2,
    Baseline = 3,
    Bottom = 4,
    Descender = 5,
}


---@class TextAlign
---@field Hor RSAlignHor
---@field Ver RSAlignVer
---@field Default fun():TextAlign
---@field Clone fun():Text
---@field ToString fun():string

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

    ---Clones the TextAlign
    ---@return TextAlign
    function s.Clone()
        return TextAlign.New(s.Hor, s.Ver)
    end

    function s.ToString()
        return string.format("h%d,v%d", s.Hor, s.Ver)
    end

    ---ToString meta function
    ---@param a TextAlign
    ---@return string
    function TextAlign.__tostring(a)
        return a.ToString()
    end

    return setmetatable(s, TextAlign)
end

---Creates a default text alignment
---@return TextAlign
function TextAlign.Default()
    return TextAlign.New(RSAlignHor.Left, RSAlignVer.Top)
end

---Creates a text align from the string
---@param s string
function TextAlign.FromString(s)
    if not s then return TextAlign.Default() end
    local h, v = s:match("^h(%d),v(%d)$")
    h = tonumber(h)
    v = tonumber(v)

    if h and v then
        return TextAlign.New(h, v)
    end

    return TextAlign.Default()
end

---@param a TextAlign
---@param b TextAlign
---@return unknown
function TextAlign.__eq(a, b)
    return a.Hor == b.Hor and a.Ver == b.Ver
end

return TextAlign
