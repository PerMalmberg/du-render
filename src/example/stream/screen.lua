if not stream then
    Stream = require("Stream")
    screen = require("Screen").Instance()
    Font = require("Font")
    Color = require("Color")

    middle = screen.Bounds() / 2

    local displayData = function(data)
        local layer = screen.Layer(1)
        local font = Font.Get(FontName.Play, 30)
        local t = layer.Text(data, middle, font)
        t.Props.Fill = Color.New(0, 2, 0)
        stream.Write("A")
    end

    stream = Stream.New(_ENV, 100, displayData)
end

stream.OnUpdate(1)

screen.Animate(1)
