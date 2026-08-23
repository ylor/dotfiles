local hs = hs ---@diagnostic disable-line: undefined-global

function ShowClipboard()
    hs.eventtap.keyStroke({ "cmd" }, "space", 0)
    hs.timer.doAfter(0.02, function()
        hs.eventtap.keyStroke({ "cmd" }, "4", 0)
    end
    )
end

_G.MouseScrollReverser = hs.eventtap.new({ hs.eventtap.event.types.scrollWheel }, function(e)
    local p = hs.eventtap.event.properties
    if e:getProperty(p.eventSourceStateID) ~= 1 then
        return false -- not real hardware input, leave it alone
    end
    if e:getProperty(p.scrollWheelEventIsContinuous) == 0 then
        e:setProperty(p.scrollWheelEventDeltaAxis1,
            -e:getProperty(p.scrollWheelEventDeltaAxis1))
    end
    return false
end):start()
