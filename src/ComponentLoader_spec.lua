local ComponentLoader = require("ComponentLoader")
local Screen          = require("native/Screen")
local Behaviour       = require("Behaviour")
local Binder          = require("Binder")
local json            = require("dkjson")
local rs              = require("native/RenderScript").Instance()
local TextAlign       = require("native/TextAlign")
local Color           = require("native/Color")
local Stream          = require("Stream")

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

rs.Log = print

local fakeStream = { setScriptInput = function() end, clearScriptOutput = function() end,
    getScriptOutput = function() return "" end }

describe("ComponentLoader", function()
    local screen = Screen.New()
    local behaviour = Behaviour.New()
    local binder = Binder.New()
    local c = ComponentLoader.New(screen, behaviour, binder, fakeStream)
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

    it("Can load pages", function()
        local pages = c.Pages()
        local pagename = pages["pagename"]
    end)

    -- $string(path{path/to/data:key}:format{My command: '%s'}:interval{1}:init{init value})
    -- $num(path{path/to/data:key}:interval{1}:init{init value}:op{mul})
    -- $vec2(xpath{-:-}:ypath{gauge/fuel:value}:init{(202,2)}:interval{0.1}:op{mul})

    --[[ it("Bind string pattern", function()
        local a = "$bind(path/to/data:key:Text with tripple colon in format string:a: '%s'::1)"
        local bind = ComponentLoader.GetBindValue(a)
        if bind == nil then
            assert.False(true)
        else
            assert.are_equal("path/to/data", bind.path)
            assert.are_equal("key", bind.key)
            assert.are_equal("Text with tripple colon in format string:a: '%s':", bind.format)
            assert.are_equal(1, bind.interval)
        end
    end)

    it("Bind number pattern", function()
        local a = "$bindNumber(path/to/data:key:Text with tripple colon in format string:a: '%f'::1)"
        local bind = ComponentLoader.GetBindValue(a)
        if bind == nil then
            assert.False(true)
        else
            assert.are_equal("path/to/data", bind.path)
            assert.are_equal("key", bind.key)
            assert.are_equal("Text with tripple colon in format string:a: '%f':", bind.format)
            assert.are_equal(1, bind.interval)
        end
    end)

    it("Can bind vec2 pattern", function()

    end) ]]
end)
