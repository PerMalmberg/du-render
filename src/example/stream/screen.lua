if not _ENV.screen then
    _ENV.screen   = require("native/Screen").New()
    _ENV.binder   = require("Binder").New()
    _ENV.behavior = require("Behaviour").New()
    _ENV.json     = require("dkjson")

    local onDataReceived = function(data)
        local j = _ENV.json.decode(data)
        if j then
            if j.screen_layout then
                if not _ENV.loader.Load(j.screen_layout) then
                    logMessage("Could not load layout")
                end
            else
                binder.MergeData(j)
            end
        end
    end

    local timeoutCallback = function(isTimedOut, stream)

    end

    _ENV.stream = require("Stream").New(_ENV, onDataReceived, 1, timeoutCallback)
    _ENV.loader = require("ComponentLoader").New(_ENV.screen, _ENV.behavior, _ENV.binder, _ENV.stream)
end

_ENV.stream.Tick()
_ENV.behavior.TriggerEvents(_ENV.screen)
_ENV.binder.Render()
_ENV.screen.Animate(1, true)
