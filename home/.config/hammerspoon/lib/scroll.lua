---@diagnostic disable-next-line: undefined-global
local hs = hs

local props = hs.eventtap.event.properties
local isTrackpad = props.scrollWheelEventIsContinuous
local verticalScrollDelta = props.scrollWheelEventDeltaAxis1

_G.scrollReverseTap = hs.eventtap.new({ hs.eventtap.event.types.scrollWheel }, function(event)
    -- Ignore trackpad events to only target physical mouse wheels
    if event:getProperty(isTrackpad) == 1 then
        return false
    end

    -- Fetch, invert, and set the Y-axis delta
    local delta = event:getProperty(verticalScrollDelta)
    event:setProperty(verticalScrollDelta, -delta)

    return false
end)

_G.scrollReverseTap:start()
