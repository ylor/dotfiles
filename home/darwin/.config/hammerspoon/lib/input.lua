local hs = hs ---@diagnostic disable-line: undefined-global

function ShowClipboard()
    hs.eventtap.keyStroke({ "cmd" }, "space", 0)
    hs.timer.doAfter(0.1, function()
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

-- LG ignores the standard input switch and can't report its input,
-- so use LG's alt addressing and remember where we sent it.
local onHdmi = true

function ToggleMonitorInput()
    onHdmi = not onHdmi
    local input = onHdmi and 144 or 208 -- HDMI 1 or DP 1
    hs.execute('/opt/homebrew/bin/betterdisplaycli set --name="LG ULTRAGEAR+" --ddcAlt --vcp=inputSelectAlt --value=' .. input)
end
