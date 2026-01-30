---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Launch, focus or cycle through instances of an application
local windowApp = ""
local windowList = {}
local windowIndex = 0
local function AppHandler(app)
    local filter = hs.window.filter.new(app):setScreens(hs.screen.mainScreen():getUUID())
    local windows = filter:getWindows(hs.window.filter.sortByFocusedLast)
    local focused = hs.window.focusedWindow()

    local newApp = windowApp ~= app
    local newCycle = windowList == {} or #windows ~= #windowList
    local newFocus = focused ~= windowList[windowIndex]

    if newApp or newCycle or newFocus then
        windowApp = app
        windowList = windows
        windowIndex = 1
    end

    if #windows >= 1 then
        windowIndex = (windowIndex % #windowList) + 1
        windowList[windowIndex]:focus()
    else
        hs.application.launchOrFocus(app)
    end
end

function App(mods, key, app)
    hs.hotkey.bind(mods, key, function()
        AppHandler(app)
    end)
end

function Tui(mods, key, bin)
    hs.hotkey.bind(mods, key, function()
        local terminal =
        "/usr/bin/open -na /Applications/Ghostty.app --args --confirm-close-surface=false --quit-after-last-window-closed=true --window-decoration=none --command="
        hs.execute(terminal .. bin)
        hs.timer.doAfter(0.5, function()
            WindowFloat()
        end)
    end)
end

function Web(mods, key, url)
    hs.hotkey.bind(mods, key, function()
        hs.execute("open " .. url)
        hs.timer.doAfter(0.5, function()
            WindowCenter()
        end)
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

-- if not AppExists("Maccy") then
hs.hotkey.bind({ "cmd", "shift" }, "v", function()
    hs.eventtap.keyStroke({ "cmd" }, "space", 0)
    hs.timer.doAfter(0.1, function()
        hs.eventtap.keyStroke({ "cmd" }, "4", 0)
    end)
end)
-- end

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
