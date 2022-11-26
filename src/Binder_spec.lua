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

    it("Can create regular Vec2 bindings, number version", function()
        local b = Binder.New()
        local target = {}
        assert.True(b.CreateBinding("$vec2(path{path:vec2}:init{(4.5,6.7)}:interval{0})"
            , target, "Prop"))
        assert.Equal(Vec2.New(4.5, 6.7), target.Prop)
        b.MergeData({ path = { vec2 = { x = 2, y = 3 } } })
        b.Render()
        assert.Equal(Vec2.New(2, 3), target.Prop)
    end)

    it("Can create regular Vec2 bindings, string version", function()
        local b = Binder.New()
        local target = {}
        assert.True(b.CreateBinding("$vec2(path{path:vec2}:init{(4.5,6.7)}:interval{0})"
            , target, "Prop"))
        assert.Equal(Vec2.New(4.5, 6.7), target.Prop)
        b.MergeData({ path = { vec2 = "(-2,-3)" } })
        b.Render()
        assert.Equal(Vec2.New(-2, -3), target.Prop)
    end)

    it("Handles invalid init value for Vec2 bindings", function()
        local b = Binder.New()
        local target = {}
        assert.False(b.CreateBinding("$vec2(path{path:vec2}:init{(X,X)}:interval{0})"
            , target, "Prop"))
    end)

    it("Can create multiplying Vec2 bindings, number version", function()
        local b = Binder.New()
        local target = {}
        assert.True(b.CreateBinding("$vec2(path{path:vec2}:init{(4.5,6.7)}:interval{0}:op{mul})"
            , target, "Prop"))
        assert.Equal(Vec2.New(4.5, 6.7), target.Prop)
        b.MergeData({ path = { vec2 = { x = 2, y = 3 } } })
        b.Render()
        assert.Equal(Vec2.New(4.5 * 2, 6.7 * 3), target.Prop)
    end)

    it("Can create multiplying Vec2 bindings, string version", function()
        local b = Binder.New()
        local target = {}
        assert.True(b.CreateBinding("$vec2(path{path:vec2}:init{(4.5,6.7)}:interval{0}:op{mul})"
            , target, "Prop"))
        assert.Equal(Vec2.New(4.5, 6.7), target.Prop)
        b.MergeData({ path = { vec2 = "(2,3)" } })
        b.Render()
        assert.Equal(Vec2.New(4.5 * 2, 6.7 * 3), target.Prop)
    end)

    it("Can create dividing Vec2 bindings, number version", function()
        local b = Binder.New()
        local target = {}
        assert.True(b.CreateBinding("$vec2(path{path:vec2}:init{(4.5,6.7)}:interval{0}:op{div})"
            , target, "Prop"))
        assert.Equal(Vec2.New(4.5, 6.7), target.Prop)
        b.MergeData({ path = { vec2 = { x = 2, y = 3 } } })
        b.Render()
        assert.Equal(Vec2.New(4.5 / 2, 6.7 / 3), target.Prop)
    end)

    it("Can create dividing Vec2 bindings, string version", function()
        local b = Binder.New()
        local target = {}
        assert.True(b.CreateBinding("$vec2(path{path:vec2}:init{(4.5,6.7)}:interval{0}:op{div})"
            , target, "Prop"))
        assert.Equal(Vec2.New(4.5, 6.7), target.Prop)
        b.MergeData({ path = { vec2 = "(2,3)" } })
        b.Render()
        assert.Equal(Vec2.New(4.5 / 2, 6.7 / 3), target.Prop)
    end)

    it("Handles missing init value", function()
        local b = Binder.New()
        local target = {}
        assert.False(b.CreateBinding("$vec2(path{path:vec2}:interval{0}:op{mul})"
            , target, "Prop"))
    end)

    it("Handles missing path or key", function()
        local b = Binder.New()
        local target = {}
        assert.False(b.CreateBinding("$vec2(path{path}:init{(4.5,6.7)}:interval{0}:op{mul})"
            , target, "Prop"))
        assert.False(b.CreateBinding("$vec2(init{(4.5,6.7)}:interval{0}:op{mul})"
            , target, "Prop"))
    end)

    it("Can create number bindnig", function()
        local b = Binder.New()
        local target = {}
        assert.True(b.CreateBinding("$num(path{path:number}:init{12.34}:interval{0})"
            , target, "Prop"))
        assert.Equal(12.34, target.Prop)
        b.MergeData({ path = { number = 78.9 } })
        b.Render()
        assert.Equal(78.9, target.Prop)
    end)

    it("Can handle invalid init value for number binding", function()
        local b = Binder.New()
        local target = {}
        assert.False(b.CreateBinding("$num(path{path:number}:init{X}:interval{0})"
            , target, "Prop"))
    end)

    it("Can do percent binding for Vec2", function()
        local b = Binder.New()
        local target = {}
        assert.True(b.CreateBinding("$vec2(path{path:vec2}:init{(0,0)}:interval{0}:percent{(10,10)})"
            , target, "Prop"))
        assert.Equal(Vec2.New(0, 0), target.Prop)
        b.MergeData({ path = { vec2 = "(0.5,0.5)" } })
        b.Render()
        assert.Equal(Vec2.New(5, 5), target.Prop)
        b.MergeData({ path = { vec2 = "(0.5,1)" } })
        b.Render()
        assert.Equal(Vec2.New(5, 10), target.Prop)
        b.MergeData({ path = { vec2 = "(0.9,0.1)" } })
        b.Render()
        assert.Equal(Vec2.New(9, 1), target.Prop)
    end)

    it("Handles bad percent value in Vec2 binding", function()
        local b = Binder.New()
        local target = {}
        assert.False(b.CreateBinding("$vec2(path{path:vec2}:init{(0,0)}:interval{0}:percent{(foo)})"
            , target, "Prop"))
    end)

    it("Can do percent binding for number", function()
        local b = Binder.New()
        local target = {}
        assert.True(b.CreateBinding("$num(path{:num}:init{0}:interval{0}:percent{-10})"
            , target, "Prop"))
        assert.Equal(0, target.Prop)
        b.MergeData({ num = 1 })
        b.Render()
        assert.are_equal(-10, target.Prop)
    end)

    it("Handle bad percent value in number bindings", function()
        local b = Binder.New()
        local target = {}
        assert.False(b.CreateBinding("$num(path{:num}:init{0}:interval{0}:percent{foo})"
            , target, "Prop"))
    end)

    it("Can get a number in a tree", function()
        local a = { b = { c = { d = 5 } } }
        local aa = { b = { c = { d = "foo" } } }
        assert.are_equal(5, Binder.GetNumByPath(a, "b/c/d"))
        assert.are_equal(nil, Binder.GetNumByPath(aa, "b/c/d"))
        assert.are_equal(nil, Binder.GetNumByPath(a, "b/c/d/d"))
    end)

    it("Can get a string in a tree", function()
        local a = { b = { c = { d = "5" } } }
        local aa = { b = { c = { d = 5 } } }
        assert.are_equal("5", Binder.GetStrByPath(a, "b/c/d"))
        assert.are_equal(nil, Binder.GetStrByPath(aa, "b/c/d"))
        assert.are_equal(nil, Binder.GetStrByPath(a, "b/c/d/d"))
    end)

    it("Can get a table in a tree", function()
        local a = { b = { c = { d = "5" } } }
        local r = Binder.GetTblByPath(a, "b/c")
        assert.are_equal("5", r.d)
        assert.are_equal(nil, Binder.GetTblByPath(a, "b/c/d"))
        assert.are_equal(nil, Binder.GetTblByPath(a, "b/c/d/d"))
    end)

    it("Can get table from first level", function()
        local a = { b = 1 }
        assert.are_equal(1, Binder.GetNumByPath(a, "b"))
        assert.are_equal(nil, Binder.GetNumByPath(a, "b/c"))
    end)
end)
