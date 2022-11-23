local env = require("environment")

env.Prepare()
local rs   = require("native/RenderScript").Instance()
rs.GetTime = getTime
rs.Log     = print

local Binder = require("Binder")
local Color  = require("native/Color")
local Vec2   = require("native/Vec2")

describe("Binder", function()

    it("Can bind to a text and number", function()
        local b = Binder.New()
        local p1 = b.Path("a/b_c/de")
        local p2 = b.Path("a/b_c/de/f")

        local obj1 = {}
        local obj2 = {}
        local obj3 = {}
        local obj4 = {}
        local obj5 = {}

        p1.Number(obj3, "Number", "num", nil, 1, function(n)
            return n * 2
        end)
        p1.Number(obj4, "Number", "num")

        p1.Number(obj5, "Number", "num", "Made into a string %0.1f")

        p2.Text(obj1, "Text", "text", "Format string %s goes here")
        p2.Text(obj2, "Text", "text")

        b.MergeData({ a = { b_c = { de = { num = 123.456, f = { text = "a text" } } } } })
        b.Render()

        assert.are_equal("Format string a text goes here", obj1.Text)
        assert.are_equal("a text", obj2.Text)
        assert.are_equal(246.912, obj3.Number)
        assert.are_equal(123.456, obj4.Number)
        assert.are_equal("Made into a string 123.5", obj5.Number)
    end)

    it("Can bind to a Color", function()
        local b = Binder.New()
        local p1 = b.Path("a/b")

        local obj1 = {}

        p1.Color(obj1, "Color", "color")

        b.MergeData({ a = { b = { color = "r1,g2,b3,a1", c = {} } } })
        b.Render()

        assert.are_equal(Color.New(1, 2, 3, 1), obj1.Color)
    end)

    it("Can bind to a Vec2", function()
        local b = Binder.New()
        local p1 = b.Path("a")

        local obj1 = {}

        p1.Vec2(obj1, "Pos", "pos")

        b.MergeData({ a = { pos = "(4,5)" } })
        b.Render()

        assert.are_equal(Vec2.New(4, 5), obj1.Pos)
    end)

    it("Can prevent updates based on time", function()
        local b = Binder.New()
        local p1 = b.Path("a", 1)

        local obj1 = {}

        p1.Vec2(obj1, "Pos", "pos")

        b.MergeData({ a = { pos = "(4,5)" } })
        b.Render()
        assert.are_equal(Vec2.New(4, 5), obj1.Pos)

        -- Doesn't take effect
        b.MergeData({ a = { pos = "(6,7)" } })
        b.Render()
        assert.are_equal(Vec2.New(4, 5), obj1.Pos)

        local now = rs.GetTime()
        while rs.GetTime() - now < 1.1 do
            -- Wait a bit
        end

        -- Takes effect
        b.Render()
        assert.are_equal(Vec2.New(6, 7), obj1.Pos)
    end)

    it("Can create string binding from expression", function()
        local b = Binder.New()
        local target = {}
        assert.True(b.CreateBinding("$str(path{path/to/data:key}:format{My command: '%s'}:interval{0.5}:init{init value}:op{mul})"
            , target, "Prop"))
        assert.Equal("init value", target.Prop)

        b.MergeData({ path = { to = { data = { key = "string value" } } } })
        b.Render()
        b.MergeData({ path = { to = { data = { key = "this is delayed" } } } })
        b.Render()
        assert.Equal("My command: 'string value'", target.Prop)

        local now = rs.GetTime()
        while rs.GetTime() - now <= 0.5 do
            -- Wait a bit
        end

        b.Render()
        assert.Equal("My command: 'this is delayed'", target.Prop)
    end)

    it("Can create string binding from expression without a format string or interval", function()
        local b = Binder.New()
        local target = {}
        assert.True(b.CreateBinding("$str(path{path/to/data:key}:init{init value}:op{mul})"
            , target, "Prop"))
        assert.Equal("init value", target.Prop)

        b.MergeData({ path = { to = { data = { key = "string value" } } } })
        b.Render()
        assert.Equal("string value", target.Prop)
    end)
end)
