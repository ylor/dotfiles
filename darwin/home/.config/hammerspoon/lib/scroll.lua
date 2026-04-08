---@diagnostic disable-next-line: undefined-global
local hs          = hs

local props       = hs.eventtap.event.properties
_G.scrollReverser = hs.eventtap.new({ hs.eventtap.event.types.scrollWheel }, function(event)
    if event:getProperty(props.scrollWheelEventIsContinuous) ~= 1 then
        event:setProperty(props.scrollWheelEventDeltaAxis1, -event:getProperty(props.scrollWheelEventDeltaAxis1))
    end
end):start()
