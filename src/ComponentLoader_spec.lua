local ComponentLoader = require("ComponentLoader")
local Screen          = require("Screen")
local json            = require("dkjson")
local rs              = require("RenderScript").Instance()
local TextAlign       = require("TextAlign")

local function loadFile(path)
    local f = io.open(path)
    if f == nil then
        error("Could not lod file " .. path)
    end
    local s = f:read("a")
    return s
end

rs.LoadFont = function(name, size)
    return 1
end

describe("ComponentLoader", function()
    it("Can load fonts", function()
        local screen = Screen.New()
        local c = ComponentLoader.New(screen)
        local s = loadFile("src/example/layout.json")
        c.Load(json.decode(s))

        local styles = c.Styles()
        local button1 = styles["button1"]
        assert.is_not_nil(button1)

        assert.are_equal(TextAlign.New(RSAlignHor.Left, RSAlignVer.Top), button1.Align)

    end)
end)
