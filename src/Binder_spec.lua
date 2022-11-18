local env = require("environment")

env.Prepare()
local rs   = require("native/RenderScript")
rs.GetTime = getTime

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

        p1.Number(obj3, "Number", "num", "%0.1f")
        p1.Number(obj4, "Number", "num", "%0.2f")

        p2.Text(obj1, "Text", "text")
        p2.Text(obj2, "Text", "text")

        b.MergeData({ a = { b_c = { de = { num = 123.456, f = { text = "a text" } } } } })
        b.Render()

        assert.are_equal("a text", obj1.Text)
        assert.are_equal("a text", obj2.Text)
        assert.are_equal("123.5", obj3.Number)
        assert.are_equal("123.46", obj4.Number)
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
end)
