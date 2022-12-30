local Layout    = require("Layout")
local Screen    = require("native/Screen")
local Behaviour = require("Behaviour")
local Binder    = require("Binder")
local json      = require("dkjson")
local rs        = require("native/RenderScript").Instance()
local TextAlign = require("native/TextAlign")
local Color     = require("native/Color")

local function loadFile(path)
    local f = io.open(path)
    if f == nil then
        error("Could not load file " .. path)
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

rs.Log = print

local fakeStream = { setScriptInput = function() end, clearScriptOutput = function() end,
    getScriptOutput = function() return "" end }

describe("Layout", function()
    local c, s, screen, behavior, binder

    before_each(function()
        screen = Screen.New()
        behavior = Behaviour.New()
        binder = Binder.New()
        c = Layout.New(screen, behavior, binder, fakeStream)
        s = loadFile("src/test_layouts/layout.json")
        assert.True(c.SetLayout(json.decode(s)))
    end)

    it("Can load fonts", function()
        local play10 = c.Fonts()["Play10"]
        assert.is_not_nil(play10)
        local montserrat100 = c.Fonts()["Montserrat100"]
        assert.is_not_nil(montserrat100)
    end)

    it("Can load styles", function()
        local styles = c.Styles()
        local testStyle = styles["blue_green_border"]
        assert.is_not_nil(testStyle)

        assert.are_equal(TextAlign.New(RSAlignHor.Left, RSAlignVer.Top), testStyle.Align)
        assert.are_equal(Color.FromString("r0.000,g1.000,b0.000,a1.000"), testStyle.Stroke.Color)
        assert.are_equal(1, testStyle.Stroke.Distance)
        assert.are_equal(45, testStyle.Rotation)
        assert.are_equal(Color.FromString("r0.200,g0.000,b0.000,a1.000"), testStyle.Shadow.Color)
        assert.are_equal(2, testStyle.Shadow.Distance)

        local style2 = styles["transparent_red_border"]
        assert.is_not_nil(style2)
    end)


    it("Can activate a page", function()
        assert.False(c.Activate("does not exist"))
        local layers, comps = screen.CountParts()
        assert.are_equal(0, layers)
        assert.are_equal(0, comps)

        assert.True(c.Activate("firstpage"))
        layers, comps = screen.CountParts()
        assert.are_equal(3, layers)
        assert.are_equal(16, comps)
    end)
end)
