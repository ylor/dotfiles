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
    if isTrackpad == 1 then
        return false -- trackpad: pass the event along
    end

    event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1,
        -event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1))
    return false -- pass the event along
end):start()

-- WindowFilter = hs.window.filter.new({
--     override = {
--         visible = true,
--     }
-- }):setDefaultFilter({
--     visible = true,
-- })
-- WindowFilter:subscribe(hs.window.filter.windowFocused, function(window)
--     CenterMouse(window)
-- end)

-- Global table to store mouse button event counts for reference (optional, but useful)
-- local mouseButtonCounts = {}

-- Function to show an alert with the pressed mouse button number
-- function ShowMouseButtonAlert(event)
--     local buttonNumber = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
--     if buttonNumber then
--         hs.alert.show("Mouse Button Pressed: " .. event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)) -- Show for 1 second
--     end
--     -- Return false to allow the event to propagate (so other handlers or default actions can still happen)
--     return false
-- end

-- -- Mouse Button 4 (usually "back")
-- hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
--     if (event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber) == 3) then
--         hs.eventtap.keyStroke({ "cmd" }, "[") -- Simulate Cmd + [ for "back"
--         return true                           -- Consume the event so it doesn't do its default action
--     end
-- end):start()

-- -- Mouse Button 5 (usually "forward")
-- hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
--     if (event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber) == 4) then
--         hs.eventtap.keyStroke({ "cmd" }, "]") -- Simulate Cmd + ] for "forward"
--         return true                           -- Consume the event so it doesn't do its default action
--     end
-- end):start()

-- -- Optional: You might also want to handle mouseUp events to ensure consistency
-- hs.eventtap.new({ hs.eventtap.event.types.otherMouseUp }, function(event)
--     if (event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber) == 3 or
--             event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber) == 4) then
--         return true -- Consume the event
--     end
-- end):start()

MouseWatcher = hs.eventtap.new({
    hs.eventtap.event.types.otherMouseDown,
    hs.eventtap.event.types.otherMouseUp
}, function(event)
    local buttonNumber = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
    local eventType = event:getType()

    if eventType == hs.eventtap.event.types.otherMouseDown then
        if buttonNumber == 3 then                 -- Mouse Button 4 (usually "back")
            hs.eventtap.keyStroke({ "cmd" }, "[") -- Simulate Cmd + [ for "back"
            return true                           -- Consume the event
        elseif buttonNumber == 4 then             -- Mouse Button 5 (usually "forward")
            hs.eventtap.keyStroke({ "cmd" }, "]") -- Simulate Cmd + ] for "forward"
            return true                           -- Consume the event
        end
        -- elseif eventType == hs.eventtap.event.types.otherMouseUp then
        --     if buttonNumber == 3 or buttonNumber == 4 then
        --         return true -- Consume the event (for consistency with the down events)
        --     end
        -- else
        --     return false
    end
end)
MouseWatcher:start()

-- To stop the watcher later, you can use:
-- myMouseBindings.mouseWatcher:stop()
