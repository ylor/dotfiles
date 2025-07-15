---@diagnostic disable-next-line: undefined-global
local hs = hs

function CenterMouse(window)
    local pos = hs.geometry(hs.mouse.absolutePosition())
    local frame = window:frame()
    if not pos:inside(frame) then
        local current_screen = hs.mouse.getCurrentScreen()
        local window_screen = window:screen()
        if current_screen and window_screen and current_screen ~= window_screen then
            -- avoid getting the mouse stuck on a screen corner by moving through the center of each screen
            hs.mouse.absolutePosition(current_screen:frame().center)
            hs.mouse.absolutePosition(window_screen:frame().center)
        end
        hs.mouse.absolutePosition(frame.center)
    end
end

ScrollWheel = hs.eventtap.new({ hs.eventtap.event.types.scrollWheel }, function(event)
    -- detect if this is touchpad or mouse
    local isTrackpad = event:getProperty(hs.eventtap.event.properties.scrollWheelEventIsContinuous)
    if isTrackpad == 1 then return false end

    event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1,
        -event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1))
end)

MouseWatcher = hs.eventtap.new({
    hs.eventtap.event.types.otherMouseDown,
    hs.eventtap.event.types.otherMouseUp
}, function(event)
    local buttonNumber = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
    local eventType = event:getType()

    if eventType == hs.eventtap.event.types.otherMouseUp then
        if buttonNumber == 3 then                 -- Mouse Button 4 (usually "back")
            hs.eventtap.keyStroke({ "cmd" }, "[") -- Simulate Cmd + [ for "back"
            return true                           -- Consume the event
        elseif buttonNumber == 4 then             -- Mouse Button 5 (usually "forward")
            hs.eventtap.keyStroke({ "cmd" }, "]") -- Simulate Cmd + ] for "forward"
            return true                           -- Consume the event
        else
            return false
        end
    end
end)

ScrollWheel:start()
MouseWatcher:start()
