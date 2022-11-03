---@alias CommQueue { queue:string[], waitingForReply:boolean, seq:integer }
---@alias ScreenLink {setScriptInput:fun(string), clearScriptOutput:fun(), getScriptOutput:fun():string}
---@alias Renderer {setOutput:fun(string), getInput:fun():string}

---@class Stream
---@field New fun(interface:ScreenLink|Renderer, onDataReceived:fun(string), timeout:number, onTimeout:fun()):Stream
---@field OnUpdate fun()
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
---@param timeout number The amount of time to wait for a reply before considering the connection broken.
---@param onTimeout fun() The function to call on a timeout
---@return Stream
function Stream.New(interface, onDataReceived, timeout, onTimeout)
    local s = {}
    local blockSize = 1024 - headerSize -- Game allows max 1024 bytes in buffers

    local runningInScreen = interface.setScriptInput == nil

    local input
    local output

    local getTime

    if _ENV["getDeltaTime"] then
        getTime = _ENV.getTime
    else
        getTime = _G.system.getUtcTime
    end

    local lastReceived = getTime()

    if runningInScreen then
        -- When running in a screen unit, use the element itself to store data.
        interface.streamInput = { queue = {}, waitingForReply = false, seq = 0 }
        interface.streamOutput = { queue = {}, waitingForReply = false, seq = 0 }
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

    ---Reads incoming data
    ---@return StreamCommand|nil #Command
    ---@return number #Packet count
    ---@return string #Payload
    local function readData()
        local r
        if runningInScreen then
            r = interface.getInput()
        else
            r = interface.getScriptOutput()
            interface.clearScriptOutput()
        end
        local count, seq, cmd, payload = r:match("^#(%d+)|(%d)|(%d+)|(.*)$")

        payload = payload or ""
        local validPacket = count and cmd
        if validPacket then
            cmd = tonumber(cmd)
            count = tonumber(count)
            validPacket = validPacket and cmd and count
        end

        if not validPacket then
            return nil, 0, ""
        end

        if runningInScreen then
            -- Since we can't clear the input, we compare the sequence number to the previous packet
            if sameInput(input, seq) then
                return nil, 0, ""
            end
        end

        return cmd, count, payload
    end

    ---Call this function in OnUpdate
    function s.OnUpdate()

        local cmd, count, payload = readData()

        -- Did we get any input?
        if cmd then
            lastReceived = getTime()
            if runningInScreen then
                local sendAck = false

                if cmd == Command.Poll or cmd == Command.Data then
                    if cmd == Command.Data then
                        assemblePackage(payload)
                        completeTransmission(count)
                    end

                    -- Send either ACK or actual data as a reply
                    if #output.queue > 0 then
                        interface.setOutput(output.queue[1])
                        table.remove(output.queue, 1)
                    else
                        sendAck = true
                    end
                elseif cmd == Command.Reset then
                    output.queue = {}
                    output.waitingForReply = false
                    input.queue = {}
                    input.waitingForReply = false
                    sendAck = true
                end

                if sendAck then
                    interface.setOutput(createBlock(0, output, Command.Ack))
                end
            else
                if cmd == Command.Data then
                    assemblePackage(payload)
                    completeTransmission(count)
                end
                -- No need to handle ACK, it's just a trigger to move on.
                output.waitingForReply = false
            end
        end

        if getTime() - lastReceived > timeout then
            onTimeout()
            output.queue = {}
            output.waitingForReply = false
        end

        if not runningInScreen and not output.waitingForReply then
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
