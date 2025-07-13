---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Variable to hold the keybind reference
local finderKeybind = nil

local function createFinderKeybind()
    if finderKeybind == nil then
        finderKeybind = hs.hotkey.bind({ "cmd" }, "l", function()
            SelectMenuItem({ "Go", "Go to Folder…" })
        end)
        print("Finder keybind registered")
    end
end

-- Function to remove the keybind
local function removeFinderKeybind()
    if finderKeybind ~= nil then
        finderKeybind:delete()
        finderKeybind = nil
        print("Finder keybind removed")
    end
end

-- Application watcher to monitor Finder activation/deactivation
FinderWatcher = hs.application.watcher.new(function(name, eventType, app)
    if name == "Finder" then
        if eventType == hs.application.watcher.activated then
            createFinderKeybind()
        elseif eventType == hs.application.watcher.deactivated then
            removeFinderKeybind()
        end
    end
end)

-- Start the application watcher
FinderWatcher:start()

-- Check if Finder is currently active and create keybind if needed
local currentApp = hs.application.frontmostApplication()
if currentApp and currentApp:name() == "Finder" then
    createFinderKeybind()
end
