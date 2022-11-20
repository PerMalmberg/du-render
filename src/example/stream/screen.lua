if not _ENV.screen then
    local layout  = library.embedFile("../../test_layouts/layout_min.json")
    _ENV.screen   = require("native/Screen").New()
    _ENV.binder   = require("Binder").New()
    _ENV.behavior = require("Behaviour").New()
    _ENV.loader   = require("ComponentLoader").New(_ENV.screen, _ENV.behavior, _ENV.binder)
    _ENV.json     = require("dkjson")

    local onDataReceived = function(data)
        local j = _ENV.json.decode(data) ---QQQ use serializer?
        if j then
            if j.screen_layout then
                _ENV.loader.Load(j.screen_layout)
            else
                binder.MergeData(j)
            end
        end
    end

    _ENV.loader.Load(json.decode(layout))

    local timeoutCallback = function(isTimedOut)

    end

    _ENV.stream = require("Stream").New(_ENV, onDataReceived, 1, timeoutCallback)
end

_ENV.stream.Tick()
_ENV.behavior.TriggerEvents(screen)
_ENV.binder.Render()
_ENV.screen.Render(true)
