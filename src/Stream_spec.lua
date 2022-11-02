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

    it("Can send and receive data from screen with latency from the screen", function()
        local screenRec = ""
        local boardRec = ""
        local msg = "a much longer message than just some simple text with some digits 1233131212 and funny characters in it | 432422| # 222. Lets see if it works."

        local screenStream ---@type Stream
        local responseFunc = function(data)
            screenRec = data
            screenStream.Write(msg)
        end

        screenStream = Stream.New(DummyRender.New(), 30, responseFunc)

        local boardStream = Stream.New(ScreenLink.New(), 30, function(data)
            boardRec = data
        end)

        boardStream.Write("1234567890")
        for i = 1, 500, 1 do
            boardStream.OnUpdate(1)
            if i % 2 == 0 then
                screenStream.OnUpdate(1)
            end
        end

        assert.are_equal("1234567890", screenRec)
        assert.are_equal(msg, boardRec)
    end)

    it("Can send and receive data from screen with latency from the screen, reversed update order", function()
        local screenRec = ""
        local boardRec = ""
        local msg = "a much longer message than just some simple text with some digits 1233131212 and funny characters in it | 432422| # 222. Lets see if it works."
        local count = 0

        local screenStream ---@type Stream
        local responseFunc = function(data)
            count = count + 1
            screenRec = data
            screenStream.Write(msg)
        end

        screenStream = Stream.New(DummyRender.New(), 30, responseFunc)

        local boardStream = Stream.New(ScreenLink.New(), 30, function(data)
            boardRec = data
        end)

        boardStream.Write("1234567890")
        for i = 1, 500, 1 do
            screenStream.OnUpdate(1)
            if i % 2 == 0 then
                boardStream.OnUpdate(1)
            end
        end

        assert.are_equal("1234567890", screenRec)
        assert.are_equal(msg, boardRec)
        assert.are_equal(count, 1)
    end)
end)
