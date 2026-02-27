---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Define a modal group for Finder-specific shortcuts
local finderKeys = hs.hotkey.modal.new()

-- Bind your key to the modal instead of the global scope
finderKeys:bind({ "cmd" }, "l", function()
    local finder = hs.application.get("Finder")
    finder:selectMenuItem({ "Go", "Go to Folder…" })
end)

-- Use a watcher to enable/disable the modal
finderWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if appName == "Finder" then
        if eventType == hs.application.watcher.activated then
            finderKeys:enter()
        elseif eventType == hs.application.watcher.deactivated then
            finderKeys:exit()
        end
    end
end)

finderWatcher:start()
