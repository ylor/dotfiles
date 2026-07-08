---@diagnostic disable-next-line: undefined-global
local hs = hs

function FinderJumpToFolder()
    hs.eventtap.keyStroke({ "cmd", "shift" }, "g", 0)
end

local scrollReverse = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

    if button == 3 then
        hs.eventtap.keyStroke({ "cmd" }, "[", 0)
        return true
    elseif button == 4 then
        hs.eventtap.keyStroke({ "cmd" }, "]", 0)
        return true
    end
    return false
end)

_G.FinderModal = AppModal("Finder",
    function() scrollReverse:start() end,
    function() scrollReverse:stop() end)
