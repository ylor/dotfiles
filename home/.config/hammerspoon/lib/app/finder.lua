---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Define a modal group for Finder-specific shortcuts
local finderKeys = hs.hotkey.modal.new()
finderKeys:bind({ "cmd" }, "l", function()
    local finder = hs.application.get("Finder")
    -- hs.eventtap.keyStroke({ "cmd", "shift" }, "g")
    finder:selectMenuItem({ "Go", "Go to Folder…" })
end)

-- Use a watcher to enable/disable the modal
appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if appName == "Finder" then
        if eventType == hs.application.watcher.activated then
            finderKeys:enter()
        elseif eventType == hs.application.watcher.deactivated then
            finderKeys:exit()
        end
    end
end)

appWatcher:start()
