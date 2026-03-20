---@diagnostic disable-next-line: undefined-global
local hs = hs

local modal = hs.hotkey.modal.new()
modal:bind({ "cmd" }, "l", function()
    hs.eventtap.keyStroke({ "cmd", "shift" }, "g")
end)


local scrollReverse = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

    if button == 3 then
        hs.eventtap.keyStroke({ "cmd" }, "[")
        return true
    elseif button == 4 then
        hs.eventtap.keyStroke({ "cmd" }, "]")
        return true
    end
    return false
end)

FinderWatcher = hs.application.watcher.new(function(appName, eventType)
    if appName ~= "Finder" then return end

    if eventType == hs.application.watcher.activated then
        modal:enter()
        scrollReverse:start()
    elseif eventType == hs.application.watcher.deactivated then
        modal:exit()
        scrollReverse:stop()
    end
end):start()
