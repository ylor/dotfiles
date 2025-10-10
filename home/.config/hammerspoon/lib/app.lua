---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Launch, focus or cycle through instances of an application
function LaunchFocusCycle(app)
    local wf = hs.window.filter.new(app):setScreens(hs.screen.mainScreen():getUUID())
    local windows = wf:getWindows("Focused")
    if #windows > 0 then
        windows[#windows]:focus()
    else
        hs.application.launchOrFocus(app)
    end
end

function App(mods, key, app)
    hs.hotkey.bind(mods, key, function()
        LaunchFocusCycle(app)
    end)
end

function Tui(mods, key, cmd)
    hs.hotkey.bind(mods, key, function()
        local terminal =
            "/usr/bin/open -na /Applications/Ghostty.app --args --confirm-close-surface=false --quit-after-last-window-closed=true --window-decoration=none --command=" ..
            cmd
        hs.execute(terminal)
        hs.timer.doAfter(0.250, function()
            WindowFloat()
        end)
    end)
end

function Web(mods, key, url)
    hs.hotkey.bind(mods, key, function()
        hs.execute("open " .. url)
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

function Unlock1Password()
    hs.execute("/opt/homebrew/bin/op account get")
end

-- APP WATCHERS
-- AppWatchers = {}

-- AppWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
--     if AppWatchers[appName] and AppWatchers[appName][eventType] then
--         AppWatchers[appName][eventType](appObject)
--     end
-- end):start()

-- local function useAppHook(appName, eventType, fn)
--     AppWatchers[appName] = AppWatchers[appName] or {}
--     AppWatchers[appName][eventType] = fn
-- end

-- local finderKeybind = nil

-- useAppHook("Finder", hs.application.watcher.activated, function(app)
--     if finderKeybind == nil then
--         finderKeybind = hs.hotkey.bind({ "cmd" }, "l", function()
--             SelectMenuItem({ "Go", "Go to Folder…" })
--         end)
--     end
-- end)

-- useAppHook("Finder", hs.application.watcher.deactivated, function(app)
--     if finderKeybind ~= nil then
--         finderKeybind:delete()
--         finderKeybind = nil
--     end
-- end)

finderKeybind = nil
finderwatcher = hs.application.watcher.new(function(app, event)
    if event == hs.application.watcher.activated then
        if app == "Finder" then
            if finderKeybind == nil then
                finderKeybind = hs.hotkey.bind({ "cmd" }, "l", function()
                    SelectMenuItem({ "Go", "Go to Folder…" })
                end)
            end
        end
    end

    if event == hs.application.watcher.deactivated then
        if app == "Finder" then
            if finderKeybind ~= nil then
                finderKeybind:delete()
                finderKeybind = nil
            end
        end
    end
end)
finderwatcher:start()
