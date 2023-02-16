local env = require("environment")

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
    env.Prepare()

    it("Can send data to screen", function()
        local screenRec = ""
        local boardRec = ""
        local screenTimeout = false
        local boardTimeout = false

        local screenStream = Stream.New(DummyRender.New(), function(data)
            screenRec = data
        end, 1, function(isTimedOut)
            screenTimeout = isTimedOut
        end)
        local boardStream = Stream.New(ScreenLink.New(), function(data)
            boardRec = data
        end, 1, function(isTimedOut)
            boardTimeout = isTimedOut
        end)

        boardStream.Write("1234567890")
        for i = 1, 5, 1 do
            boardStream.Tick()
            screenStream.Tick()
        end

        assert.are_equal("1234567890", screenRec)
        assert.is_false(screenTimeout)
        assert.is_false(boardTimeout)
    end)

    it("Can receive data from screen", function()
        local screenRec = ""
        local boardRec = ""
        local screenTimeout = false
        local boardTimeout = false

        local screenStream = Stream.New(DummyRender.New(), function(data)
            screenRec = data
        end, 1, function(isTimedOut)
            screenTimeout = isTimedOut
        end)
        local boardStream = Stream.New(ScreenLink.New(), function(data)
            boardRec = data
        end, 1, function(isTimedOut)
            boardTimeout = isTimedOut
        end)

        screenStream.Write("1234567890")
        for i = 1, 5, 1 do
            boardStream.Tick()
            screenStream.Tick()
        end

        assert.are_equal("1234567890", boardRec)
        assert.is_false(screenTimeout)
        assert.is_false(boardTimeout)
    end)

    it("Can send and receive data from screen with latency from the screen", function()
        local screenRec = ""
        local boardRec = ""
        local screenTimeout = false
        local boardTimeout = false

        local msg =
        "a much longer message than just some simple text with some digits 1233131212 and funny characters in it | 432422| # 222. Lets see if it works."

        local screenStream ---@type Stream
        local responseFunc = function(data)
            screenRec = data
            screenStream.Write(msg)
        end

        screenStream = Stream.New(DummyRender.New(), responseFunc, 1, function(isTimedOut)
            screenTimeout = isTimedOut
        end)

        local boardStream = Stream.New(ScreenLink.New(), function(data)
            boardRec = data
        end, 1, function(isTimedOut)
            boardTimeout = isTimedOut
        end)

        boardStream.Write("1234567890")
        for i = 1, 500, 1 do
            boardStream.Tick()
            if i % 2 == 0 then
                screenStream.Tick()
            end
        end

        assert.are_equal("1234567890", screenRec)
        assert.are_equal(msg, boardRec)
        assert.is_false(screenTimeout)
        assert.is_false(boardTimeout)
    end)

    it("Can send and receive data from screen with latency from the screen, reversed update order", function()
        local screenRec = ""
        local boardRec = ""
        local screenTimeout = false
        local boardTimeout = false

        local msg =
        [[a much longer message than just some simple text with some digits 1233131212 and funny characters in it | 432422| # 222.
                    Lets see if it works? We can surely hope, can't we? What if we add some more funny characters to make it even longer?
                    )/%(&(%&¤&#¤&&¤/%&(¤(&/¤()&/(%%/((&/¤%/%#/#¤¤&¤&¤))))))) and then even more keyboard bashing. nghengwtangwnihe wnergeioger
                    gerjlgeraeragegerghearhgrwahgöoegjeargjnelaöighjnaewögerawg  geg ergeag jera jgaerj öae gäae gäaerj gäpear ägajeijg re]]
        local count = 0

        local screenStream ---@type Stream
        local responseFunc = function(data)
            count = count + 1
            screenRec = data
            screenStream.Write(msg)
        end

        screenStream = Stream.New(DummyRender.New(), responseFunc, 1, function(isTimedOut)
            screenTimeout = isTimedOut
        end)

        local boardStream = Stream.New(ScreenLink.New(), function(data)
            boardRec = data
        end, 1, function(isTimedOut)
            boardTimeout = isTimedOut
        end)

        boardStream.Write(msg)
        for i = 1, 500, 1 do
            screenStream.Tick()
            if i % 2 == 0 then
                boardStream.Tick()
            end
        end

        assert.are_equal(msg, screenRec)
        assert.are_equal(msg, boardRec)
        assert.are_equal(1, count)
        assert.is_false(screenTimeout)
        assert.is_false(boardTimeout)
    end)

    it("Can handle a timeout", function()
        local screenTimeout = false
        local boardTimeout = false

        local msg =
        "a much longer message than just some simple text with some digits 1233131212 and funny characters in it | 432422| # 222. Lets see if it works."

        local screenStream ---@type Stream
        local responseFunc = function(data)
            screenStream.Write(msg)
        end

        screenStream = Stream.New(DummyRender.New(), responseFunc, 0.5, function(isTimedOut)
            screenTimeout = isTimedOut
        end)

        local boardStream = Stream.New(ScreenLink.New(), function(data)
        end, 0.5, function(isTimedOut)
            boardTimeout = isTimedOut
        end)

        local start = system.getUtcTime()

        -- No timeout while just sending polls
        while system.getUtcTime() - start < 1 do
            boardStream.Tick()
            screenStream.Tick()
        end

        assert.is_false(boardTimeout)
        assert.is_false(screenTimeout)

        -- No timeout when sending data
        start = system.getUtcTime()
        while system.getUtcTime() - start < 1 do
            boardStream.Tick()
            screenStream.Tick()
        end

        assert.is_false(boardTimeout)
        assert.is_false(screenTimeout)

        -- Timeout when not receiveing replies
        start = system.getUtcTime()
        while system.getUtcTime() - start < 1 do
            boardStream.Tick()
        end

        assert.is_true(boardTimeout)
        assert.is_false(screenTimeout)

        -- Resume comms
        start = system.getUtcTime()

        while system.getUtcTime() - start < 1 do
            boardStream.Tick()
            screenStream.Tick()
        end

        assert.is_false(boardTimeout)
        assert.is_false(screenTimeout)
    end)

    it("Can send structured data", function()
        local screenRec
        local boardRec
        local screenTimeout = false
        local boardTimeout = false

        local screenStream = Stream.New(DummyRender.New(), function(data)
            screenRec = data
        end, 1, function(isTimedOut)
            screenTimeout = isTimedOut
        end)

        local boardStream
        boardStream = Stream.New(ScreenLink.New(), function(data)
            boardRec = data
            boardStream.Write({ abc = { def = { v = 123 } } })
        end, 1, function(isTimedOut)
            boardTimeout = isTimedOut
        end)

        screenStream.Write({ foo = "bar" })
        for i = 1, 5, 1 do
            boardStream.Tick()
            screenStream.Tick()
        end

        assert.are_equal("bar", boardRec.foo)
        assert.are_equal(123, screenRec.abc.def.v)
        assert.is_false(screenTimeout)
        assert.is_false(boardTimeout)
    end)
end)
