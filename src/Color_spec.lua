local Color = require("Color")

describe("Color", function()
    it("Can create Color", function()
        local c = Color.New(.1, .2, .3)
        assert.are_equal(.1, c.Red)
        assert.are_equal(.2, c.Green)
        assert.are_equal(.3, c.Blue)
        assert.are_equal(1, c.Alpha)
    end)

    it("Clamps colors to 0-5 and alpha to 0.1", function()
        local c = Color.New(-1, 2, 6, 2)
        assert.are_equal(0, c.Red)
        assert.are_equal(2, c.Green)
        assert.are_equal(5, c.Blue)
        assert.are_equal(1, c.Alpha)

        c = Color.New(-1, 2, 6, -1)
        assert.are_equal(0, c.Alpha)
    end)

    it("Can print as string", function()
        local c = Color.New(.1, .2, .3, .4)
        assert.are_equal("r: 0.100, g: 0.200, b: 0.300, a: 0.400", tostring(c))
    end)

    it("Can create a transparent color", function()
        local transparent = Color.Transparent()
        assert.are_equal(0, transparent.Alpha)
    end)
end)
