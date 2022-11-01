---@alias CommQueue { queue:string[], waitingForReply:boolean }
---@alias ScreenLink {setScriptInput:fun(string), clearScriptOutput:fun(), getScriptOutput:fun():string}
---@alias Renderer {setOutput:fun(string), getInput:fun():string}

---@class Stream
---@field New fun(interface:ScreenLink|Renderer, blockSize:integer, onDataReceived:fun(string)):Stream
---@field OnUpdate fun(currentTime:number)
---@field Read fun():string|nil
---@field Write fun(data:string)

--[[
    Data format:
    #remaining_chucks|cmd|payload

    Where:
    - remaining_chunks is a 2-digit integer indicating how many chunks remains to complete the message. 0 means the last chuck.
    - cmd is a two digit integer indicating what to do with the data
    - payload is the actual payload, if any
]]

local headerSize = 1 + 2 + 1 + 2 + 1

---@enum StreamCommand
local Command = {
    Reset = 0,
    Poll = 1,
    Ack = 2,
    Data = 3,
}

---Represents a stream between two entities.
local Stream = {}
Stream.__index = Stream

---Create a new Stream
---@param interface ScreenLink|Renderer Either a link to a screen or _ENV when in RenderScript
---@param blockSize integer Max number of characters in a block.
---@param onDataReceived fun(string) Callback for when data is received
---@return Stream
function Stream.New(interface, blockSize, onDataReceived)
    local s = {}
    blockSize = math.min(math.max(blockSize, headerSize), 1024 - headerSize) -- Game allows max 1024 bytes in buffers

    local runningInScreen = interface.setScriptInput == nil

    local getInput ---@type fun():CommQueue
    local getOutput ---@type fun():CommQueue
    local input = { queue = {}, waitingForReply = false }
    local output = { queue = {}, waitingForReply = false }

    if runningInScreen then
        -- When running in a screen unit, use _ENV to store data
        if not _ENV["streamInput"] then
            _ENV["streamInput"] = { queue = {}, waitingForReply = 0 }
            _ENV["streamOutput"] = { queue = {}, waitingForReply = 0 }
        end

        getInput = function() return _ENV["streamInput"] end
        getOutput = function() return _ENV["streamOutput"] end
    else
        getInput = function() return input end
        getOutput = function() return output end
    end

    ---Assembles the package
    ---@param payload string
    local function assemblePackage(payload)
        local queue = getInput().queue

        if #queue == 0 then
            table.insert(queue, "")
        end

        queue[#queue] = queue[#queue] .. payload
    end

    ---Completes a transmission
    ---@param count number
    local function completeTransmission(count)
        if count == 0 then
            local queue = getInput().queue
            onDataReceived(queue[#queue])
            -- Last part, begin new data
            queue[1] = ""
        end
    end

    ---Creates a block
    ---@param blockCount integer
    ---@param cmd StreamCommand
    ---@param payload string?
    ---@return string
    local function createBlock(blockCount, cmd, payload)
        payload = payload or ""
        local b = string.format("#%0.2d|%0.2d|%s", blockCount, cmd, payload)
        return b
    end

    ---Call this function in OnUpdate
    ---@param currentTime number Current time
    function s.OnUpdate(currentTime)
        local out = getOutput()
        local inp = getInput()

        local r
        if runningInScreen then
            r = interface.getInput()
        else
            r = interface.getScriptOutput()
            interface.clearScriptOutput()
        end
        local count, cmd, payload = r:match("^#(%d+)|(%d+)|(.*)$")

        payload = payload or ""
        local validPackage = count and cmd
        if validPackage then
            cmd = tonumber(cmd)
            count = tonumber(count)
            validPackage = validPackage and cmd and count
        end

        if runningInScreen then
            if validPackage then
                if cmd == Command.Poll and #out.queue > 0 then
                    interface.setOutput(out.queue[1])
                    table.remove(out.queue, 1)
                elseif cmd == Command.Data then
                    assemblePackage(payload)
                    interface.setOutput(createBlock(0, Command.Ack))
                    completeTransmission(count)
                elseif cmd == Command.Reset then
                    out.queue = {}
                    out.waitingForReply = false
                    inp.queue = {}
                    inp.waitingForReply = false
                else
                    interface.setOutput(createBlock(0, Command.Ack))
                end
            end
        else
            if validPackage then
                if cmd == Command.Data then
                    assemblePackage(payload)
                    completeTransmission(count)
                elseif cmd == Command.Ack then
                    out.waitingForReply = false
                end
            end

            if #out.queue == 0 or out.waitingForReply then
                interface.setScriptInput(createBlock(0, Command.Poll))
                out.waitingForReply = true
            elseif #out.queue > 0 then
                interface.setScriptInput(out.queue[1])
                table.remove(out.queue, 1)
                out.waitingForReply = true
            end
        end
    end

    ---Write the data to the stream
    ---@param data string
    function s.Write(data)
        data = data or ""
        local out = getOutput()
        local blockCount = math.ceil(data:len() / blockSize) - 1

        while data:len() > blockSize - headerSize do
            local part = data:sub(1, blockSize)
            data = data:sub(blockSize + 1)
            table.insert(out.queue, createBlock(blockCount, Command.Data, part))
            blockCount = blockCount - 1
        end

        if data:len() > 0 then
            table.insert(out.queue, createBlock(blockCount, Command.Data, data))
        end
    end

    return setmetatable(s, Stream)
end

return Stream
