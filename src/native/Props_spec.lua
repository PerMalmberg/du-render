local Props = require("native/Props")
local Color = require("native/Color")
local ColorAndDistance = require("native/ColorAndDistance")

describe("Props", function()
    it("Can load and persist", function()
        local p = Props.New(Color.New(1, 2, 3, 1), 45, ColorAndDistance.New(Color.New(3, 2, 1, 1), 12),
            ColorAndDistance.New(Color.New(2, 2, 2, 0.5), 12))
        local t = p.Persist()
        local p2 = Props.Load(t)

        assert.are_equal(p.Align, p2.Align)
        assert.are_equal(p.Fill, p2.Fill)
        assert.are_equal(p.Rotation, p2.Rotation)
        assert.are_equal(p.Shadow.Color, p2.Shadow.Color)
        assert.are_equal(p.Shadow.Distance, p2.Shadow.Distance)
        assert.are_equal(p.Stroke.Color, p2.Stroke.Color)
        assert.are_equal(p.Stroke.Distance, p2.Stroke.Distance)
    end)

end)
