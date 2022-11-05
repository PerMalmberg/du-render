local Vec2 = require("Vec2")

describe("Vec2", function()
    it("Can create a Vec2 ", function()
        local v = Vec2.New(2, 3)
        assert.are_equal(2, v.x)
        assert.are_equal(3, v.y)

        local a = Vec2.New(Vec2.New(5, 6))
        assert.are_equal(5, a.x)
        assert.are_equal(6, a.y)

        a = Vec2.New({ 7, 8 })
        assert.are_equal(7, a.x)
        assert.are_equal(8, a.y)
    end)

    it("Can do division", function()
        local v = Vec2.New(10, 4) / 2
        assert.are_equal(5, v.x)
        assert.are_equal(2, v.y)
        v = v / 2
        assert.are_equal(2.5, v.x)
        assert.are_equal(1, v.y)

        v = v / Vec2.New(2.5, 2)
        assert.are_equal(1, v.x)
        assert.are_equal(0.5, v.y)
    end)

    it("Can do multiplication", function()
        local v = Vec2.New(10, 4) * 2
        assert.are_equal(20, v.x)
        assert.are_equal(8, v.y)
        v = v * 2
        assert.are_equal(40, v.x)
        assert.are_equal(16, v.y)

        v = v * Vec2.New(2.5, 2)
        assert.are_equal(100, v.x)
        assert.are_equal(32, v.y)
    end)

    it("Can do addition", function()
        local v = Vec2.New(1, 2) + Vec2.New(3, 4)
        assert.are_equal(4, v.x)
        assert.are_equal(6, v.y)
    end)

    it("Can do subtraction", function()
        local v = Vec2.New(1, 2) - Vec2.New(1, 2)
        assert.are_equal(0, v.x)
        assert.are_equal(0, v.y)
    end)

    it("Can check equality", function()
        local a = Vec2.New(1, 2)
        local b = Vec2.New(2, 4)
        assert.is_true(a == a)
        assert.is_true(b == b)
        assert.is_false(a == b)
        assert.is_false(a ~= a)
    end)

    it("Can negate", function()
        local v = Vec2.New(1, 2)
        v = -v
        assert.are_equal(-1, v.x)
        assert.are_equal(-2, v.y)
    end)

    it("Can do tostring", function()
        assert.are_equal("(+1.000,+2.000)", string.format("%s", Vec2.New(1, 2)))
        assert.are_equal("(-1.000,-2.000)", string.format("%s", Vec2.New(-1, -2)))
    end)

    it("Can create a Vec2 from a string", function()
        local v = Vec2.FromString("(-1,+3)")
        assert.is_not_nil(v)
        assert.are_equal(-1, v.x)
        assert.are_equal(3, v.y)
    end)

end)
