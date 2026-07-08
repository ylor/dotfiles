local hs = hs ---@diagnostic disable-line: undefined-global

function SpaceInfo()
    local spaces = hs.spaces.spacesForScreen("Primary")
    local active = hs.spaces.activeSpaceOnScreen("Primary")
    return hs.fnutils.indexOf(spaces, active), #spaces
end

function MoveWindowToSpaceByDrag(space)
    local currentSpace = SpaceInfo()
    if space == currentSpace then return end

    local win = hs.window.focusedWindow()
    if not win then return end

    local zoom = win:zoomButtonRect()
    local dragPos = { x = zoom.x + zoom.w + 5, y = zoom.y + (zoom.h / 2) }
    -- local savedPos = hs.mouse.absolutePosition()

    hs.mouse.absolutePosition(dragPos)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, dragPos):post()
    hs.timer.usleep(10000)
    hs.eventtap.keyStroke({ "ctrl" }, tostring(space), 0)
    hs.timer.usleep(10000)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, dragPos):post()
    hs.timer.usleep(10000)
    hs.timer.doAfter(0.333, function() win:focus() end)
    -- hs.mouse.absolutePosition(savedPos)
end
