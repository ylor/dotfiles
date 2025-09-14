---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Launch, focus or cycle through instances of an application
function LaunchOrFocusOrCycle(app)
    if hs.window.focusedWindow():application():name() == app then
        local appWindows = hs.application.get(app):allWindows()
        if #appWindows > 0 then
            appWindows[#appWindows]:focus()
        end
    else
        hs.application.launchOrFocus(app)
    end
end

function test(app)
    local mainScreen = hs.screen.mainScreen()
    local wf = hs.window.filter.new(app):setScreens(mainScreen:id())
    local windows = wf:getWindows("Focused")
    if #windows > 0 then
        windows[#windows]:focus()
    else
        hs.application.launchOrFocus(app)
    end
end

function App(mods, key, app)
    hs.hotkey.bind(mods, key, function()
        test(app)
    end)
end

function AppExists(app)
    return hs.application.find(app)
end

function AppActive(app)
    return hs.application.get(app):isFrontmost()
end

function AppRunning(app)
    return hs.application.get(app)
end

-- hs.hotkey.bind("cmd", "i", function()
--     test("Safari")
-- end)

-- APP WATCHERS

-- Create a table to hold our app-specific functions.
-- It's a good practice to put this inside a module or a global scope to prevent
-- it from being garbage collected.
appWatchers = {}

-- The single, global application watcher.
-- Assign it to a global variable to ensure it's not garbage collected.
appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    -- Check if we have a handler for this app and event type.
    if appWatchers[appName] and appWatchers[appName][eventType] then
        -- Call the specific handler function with the application object.
        appWatchers[appName][eventType](appObject)
    end
end):start()

-- Reusable function to register a new app watcher.
function registerAppWatcher(appName, eventType, fn)
    -- Initialize the table for the app if it doesn't exist.
    appWatchers[appName] = appWatchers[appName] or {}
    -- Store the function for the specific event type.
    appWatchers[appName][eventType] = fn
end

local finderKeybind = nil

registerAppWatcher("Finder", hs.application.watcher.activated, function(app)
    if finderKeybind == nil then
        finderKeybind = hs.hotkey.bind({ "cmd" }, "l", function()
            SelectMenuItem({ "Go", "Go to Folder…" })
        end)
    end
end)


registerAppWatcher("Finder", hs.application.watcher.deactivated, function(app)
    if finderKeybind ~= nil then
        finderKeybind:delete()
        finderKeybind = nil
    end
end)

if not AppExists("Maccy") then
    hs.hotkey.bind(mod.hyper, "v", function()
        hs.eventtap.keyStroke({ "cmd" }, "space", 0)
        hs.timer.doAfter(0.1, function()
            hs.eventtap.keyStroke({ "cmd" }, "4", 0)
        end)
    end)
end
