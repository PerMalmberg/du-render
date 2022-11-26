local rs = require("native/RenderScript").Instance()
---@alias FontHandle integer

---@class LoadedFont
---@field public New fun():LoadedFont
---@field public GetID fun():FontHandle
---@field public Reset fun()

local LoadedFont = {}
LoadedFont.__index = LoadedFont

---Creates a new LoadedFont
---@param name string
---@param size integer
---@return LoadedFont
function LoadedFont.New(name, size)
    local s = {
        id = rs.LoadFont(name, size)
    }

    function s.GetID()
        if not s.id then
            s.id = rs.LoadFont(name, size)
        end

        return s.id
    end

    function s.Reset()
        s.id = nil
    end

    return setmetatable(s, LoadedFont)
end

return LoadedFont
