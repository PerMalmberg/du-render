local r = require("Render").Instance()
local Vec2 = require("Vec2")

local v = Vec2.New()


-- Gets screen resolution
local w, h = r.getResolution()

-- Creates layer
local layer = r.createLayer()

-- Gets font
local font = r.loadFont('Play', math.min(w, h) * 0.1)

-- Draws "Hello, World!" centered
r.setNextFillColor(layer, 2, 1, 0, 1)
r.setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
r.addText(layer, font, 'Hello, World!', w / 2, h / 2)
