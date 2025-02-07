local env = require("environment")
env.Prepare()
local rs         = require("native/RenderScript").Instance()
rs.GetTime       = getTime
rs.LoadImage     = function()
    return 123
end

local Layout     = require("Layout")
local Screen     = require("native/Screen")
local Behaviour  = require("Behaviour")
local Binder     = require("Binder")
local json       = require("dkjson")
local TextAlign  = require("native/TextAlign")
local Color      = require("native/Color")

rs.LoadFont      = function(name, size)
    return 1
end

rs.CreateLayer   = function()
    return 1
end

rs.GetResolution = function()
    return 10, 10
end

rs.Log           = print

local fakeStream = {
    Write = function()
    end,
    WaitingToSend = function()
        return false
    end,
    Tick = function() end
}

describe("Layout", function()
    local layout ---@type Layout
    local screen ---@type Screen
    local behavior ---@type Behaviour
    local binder ---@type Binder

    before_each(function()
        screen = Screen.New()
        behavior = Behaviour.New()
        binder = Binder.New()
        layout = Layout.New(screen, behavior, binder, fakeStream)
        local s = require("test_layouts/layout")
        assert.True(layout.SetLayout(s))
    end)

    it("Can load fonts", function()
        local play10 = layout.Fonts()["Play10"]
        assert.is_not_nil(play10)
        local montserrat100 = layout.Fonts()["Montserrat100"]
        assert.is_not_nil(montserrat100)
    end)

    it("Can load styles", function()
        local styles = layout.Styles()
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
        assert.False(layout.Activate("does not exist"))
        local layers, comps = screen.CountParts()
        assert.are_equal(0, layers)
        assert.are_equal(0, comps)
        assert.True(layout.Activate("firstpage"))
        layers, comps = screen.CountParts()
        assert.are_equal(4, layers)
        assert.are_equal(30, comps)
    end)

    it("Can activate a page with hidden items", function()
        assert.True(layout.Activate("page_with_hidden"))
        local layers, comps = screen.CountParts()
        assert.are_equal(3, layers)
        assert.are_equal(3, comps)

        layers, comps = screen.CountParts(true)
        assert.are_equal(3, layers)
        assert.are_equal(2, comps)

        binder.MergeData({ visible = true })
        binder.Render()
        layers, comps = screen.CountParts(true)
        assert.are_equal(3, layers)
        assert.are_equal(3, comps)

        binder.MergeData({ visible = false })
        binder.Render()
        layers, comps = screen.CountParts(true)
        assert.are_equal(3, layers)
        assert.are_equal(2, comps)
    end)
end)
