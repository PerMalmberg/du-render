---@alias CommQueue { queue:string[], waitingForReply:boolean, seq:integer }
---@alias ScreenLink {setScriptInput:fun(string), clearScriptOutput:fun(), getScriptOutput:fun():string}
---@alias Renderer {setOutput:fun(string), getInput:fun():string}

---@class Stream
---@field New fun(interface:ScreenLink|Renderer, blockSize:integer, onDataReceived:fun(string)):Stream
---@field OnUpdate fun(currentTime:number)
---@field Write fun(data:string)

--[[
    Data format:
    #remaining_chucks|seq|cmd|payload

    Where:
    - remaining_chunks is a 2-digit integer indicating how many chunks remains to complete the message. 0 means the last chuck.
    - seq is a single digit seqence number, used to ensure we don't read the same data twice. It wraps around at 9.
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
---@param onDataReceived fun(string) Callback for when data is received
---@return Stream
function Stream.New(interface, onDataReceived)
    local s = {}
    local blockSize = 1024 - headerSize -- Game allows max 1024 bytes in buffers

    local runningInScreen = interface.setScriptInput == nil

    local input
    local output

    if runningInScreen then
        -- When running in a screen unit, use the element itself to store data.
        interface.streamInput = { queue = {}, waitingForReply = 0, seq = 0 }
        interface.streamOutput = { queue = {}, waitingForReply = 0, seq = 0 }
        output = interface.streamInput
        input = interface.streamOutput
    else
        output = { queue = {}, waitingForReply = false, seq = 0 }
        input = { queue = {}, waitingForReply = false, seq = 0 }
    end

    ---Assembles the package
    ---@param payload string
    local function assemblePackage(payload)
        local queue = input.queue

        if #queue == 0 then
            table.insert(queue, "")
        end
        queue[#queue] = queue[#queue] .. payload
    end

    ---Completes a transmission
    ---@param count number
    local function completeTransmission(count)
        if count == 0 then
            local queue = input.queue
            onDataReceived(queue[#queue])
            -- Last part, begin new data
            queue[1] = ""
        end
    end

    local function sameInput(commQueue, seq)
        if seq == commQueue.seq then
            return true
        else
            commQueue.seq = seq
            return false
        end
    end

    ---Creates a block
    ---@param blockCount integer
    ---@param commQueue CommQueue
    ---@param cmd StreamCommand
    ---@param payload string?
    ---@return string
    local function createBlock(blockCount, commQueue, cmd, payload)
        commQueue.seq = (commQueue.seq + 1)
        if commQueue.seq > 9 then
            commQueue.seq = 0
        end

        payload = payload or ""
        local b = string.format("#%0.2d|%0.1d|%0.2d|%s", blockCount, commQueue.seq, cmd, payload)
        return b
    end

    ---Call this function in OnUpdate
    ---@param currentTime number Current time
    function s.OnUpdate(currentTime)

        local r
        if runningInScreen then
            r = interface.getInput()
        else
            r = interface.getScriptOutput()
            interface.clearScriptOutput()
        end
        local count, seq, cmd, payload = r:match("^#(%d+)|(%d)|(%d+)|(.*)$")

        payload = payload or ""
        local validPackage = count and cmd
        if validPackage then
            cmd = tonumber(cmd)
            count = tonumber(count)
            validPackage = validPackage and cmd and count
        end

        if runningInScreen then
            if validPackage then
                if sameInput(input, seq) then
                    return
                end

                if cmd == Command.Poll and #output.queue > 0 then
                    interface.setOutput(output.queue[1])
                    table.remove(output.queue, 1)
                elseif cmd == Command.Data then
                    assemblePackage(payload)
                    interface.setOutput(createBlock(0, output, Command.Ack))
                    completeTransmission(count)
                elseif cmd == Command.Reset then
                    output.queue = {}
                    output.waitingForReply = false
                    input.queue = {}
                    input.waitingForReply = false
                else
                    interface.setOutput(createBlock(0, output, Command.Ack))
                end
            end
        else
            if validPackage then
                if cmd == Command.Data then
                    assemblePackage(payload)
                    completeTransmission(count)
                    output.waitingForReply = false
                end
                -- No need to handle ACK, it's just a trigger to move on.
                output.waitingForReply = false
            end

            if not output.waitingForReply then
                if #output.queue == 0 then
                    interface.setScriptInput(createBlock(0, output, Command.Poll))
                    output.waitingForReply = true
                elseif #output.queue > 0 then
                    interface.setScriptInput(output.queue[1])
                    table.remove(output.queue, 1)
                    output.waitingForReply = true
                end
            end
        end
    end

    ---Write the data to the stream
    ---@param data string
    function s.Write(data)
        data = data or ""
        local blockCount = math.ceil(data:len() / blockSize) - 1

        while data:len() > blockSize - headerSize do
            local part = data:sub(1, blockSize)
            data = data:sub(blockSize + 1)
            table.insert(output.queue, createBlock(blockCount, output, Command.Data, part))
            blockCount = blockCount - 1
        end

        if data:len() > 0 then
            table.insert(output.queue, createBlock(blockCount, output, Command.Data, data))
        end
    end

    return setmetatable(s, Stream)
end

return Stream
