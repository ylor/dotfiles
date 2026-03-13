---@diagnostic disable-next-line: undefined-global
local hs = hs

local finderKeys = hs.hotkey.modal.new()
finderKeys:bind({ "cmd" }, "l", function()
    hs.eventtap.keyStroke({ "cmd", "shift" }, "g")
end)


local mouseWatcher = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
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
        finderKeys:enter()
        mouseWatcher:start()
    elseif eventType == hs.application.watcher.deactivated then
        finderKeys:exit()
        mouseWatcher:stop()
    end
end):start()
