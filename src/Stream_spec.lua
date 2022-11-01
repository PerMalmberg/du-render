local Stream = require("Stream")

local input = ""
local output = ""

local ScreenLink = {}
ScreenLink.__index = ScreenLink

function ScreenLink.New()
    local s = {}

    --- Programming board side
    function s.setScriptInput(inp)
        input = inp
    end

    --- Programming board side
    function s.getScriptOutput()
        return output
    end

    --- Programming board side
    function s.clearScriptOutput()
        output = ""
    end

    return setmetatable(s, ScreenLink)
end

local DummyRender = {}
DummyRender.__index = DummyRender

function DummyRender.New()
    local s = {
    }

    -- RenderScript
    function s.setOutput(out)
        output = out
    end

    -- RenderScript
    function s.getInput()
        return input
    end

    return setmetatable(s, DummyRender)
end

describe("Stream", function()
    it("Can send data to screen", function()
        local screenRec = ""
        local boardRec = ""

        local screenStream = Stream.New(DummyRender.New(), 3, function(data)
            screenRec = data
        end)
        local boardStream = Stream.New(ScreenLink.New(), 3, function(data)
            boardRec = data
        end)

        boardStream.Write("1234567890")
        for i = 1, 5, 1 do
            boardStream.OnUpdate(1)
            screenStream.OnUpdate(1)
        end

        assert.are_equal("1234567890", screenRec)
    end)

    it("Can receive data from screen", function()
        local screenRec = ""
        local boardRec = ""

        local screenStream = Stream.New(DummyRender.New(), 3, function(data)
            screenRec = data
        end)
        local boardStream = Stream.New(ScreenLink.New(), 3, function(data)
            boardRec = data
        end)

        screenStream.Write("1234567890")
        for i = 1, 5, 1 do
            boardStream.OnUpdate(1)
            screenStream.OnUpdate(1)
        end

        assert.are_equal("1234567890", boardRec)
    end)
end)
