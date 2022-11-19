local ComponentLoader = require("ComponentLoader")
local Screen          = require("native/Screen")
local Behaviour       = require("Behaviour")
local Binder          = require("Binder")
local json            = require("dkjson")
local rs              = require("native/RenderScript").Instance()
local TextAlign       = require("native/TextAlign")
local Color           = require("native/Color")

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

rs.CreateLayer = function()
    return 1
end

rs.GetResolution = function()
    return 10, 10
end

describe("ComponentLoader", function()
    local screen = Screen.New()
    local behaviour = Behaviour.New()
    local binder = Binder.New()
    local c = ComponentLoader.New(screen, behaviour, binder)
    local s = loadFile("src/test_layouts/layout.json")
    assert.True(c.Load(json.decode(s)))

    it("Can load fonts", function()
        local play10 = c.Fonts()["Play10"]
        assert.is_not_nil(play10)
        local montserrat5 = c.Fonts()["Montserrat5"]
        assert.is_not_nil(montserrat5)
    end)

    it("Can load styles", function()
        local styles = c.Styles()
        local button1 = styles["button1"]
        assert.is_not_nil(button1)

        assert.are_equal(TextAlign.New(RSAlignHor.Left, RSAlignVer.Top), button1.Align)
        assert.are_equal(Color.FromString("r2.000,g2.000,b2.000,a0.500"), button1.Stroke.Color)
        assert.are_equal(12, button1.Stroke.Distance)
        assert.are_equal(45, button1.Rotation)
        assert.are_equal(Color.FromString("r3.000,g2.000,b1.000,a1.000"), button1.Shadow.Color)
        assert.are_equal(10, button1.Shadow.Distance)

        local button1_hover = styles["button1_hover"]
        assert.is_not_nil(button1_hover)
    end)

    it("Can load pages", function()
        local pages = c.Pages()
        local pagename = pages["pagename"]

    end)

    it("Can handle missing style", function()
        --assert.False(true)
    end)
end)
