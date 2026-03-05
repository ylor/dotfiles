---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Launch, focus or cycle through instances of an application
local lastApp, windowList, windowIndex = "", {}, 0

hs.spaces.watcher.new(function()
    lastApp, windowList, windowIndex = "", {}, 0
end):start()

local primaryScreen = hs.screen.primaryScreen()

local function AppHandler(application)
    local app = hs.application.get(application)
    if not app then
        hs.application.launchOrFocus(application)
        return
    end

    local windows = {}
    for _, win in ipairs(hs.window.filter.new(false):setAppFilter(application):getWindows()) do
        if win:isStandard() and win:screen() == primaryScreen then
            windows[#windows + 1] = win
        end
    end

    if #windows == 0 then
        hs.application.launchOrFocus(application)
        return
    end

    if lastApp ~= application or #windows ~= #windowList then
        lastApp, windowList, windowIndex = application, windows, 1
    else
        windowIndex = windowIndex % #windows + 1
    end

    windowList[windowIndex]:focus()
    CenterMouse(windowList[windowIndex])
end

function App(mods, key, app)
    hs.hotkey.bind(mods, key, function()
        AppHandler(app)
    end)
end

App("alt", "I", "Google Chrome Dev")

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

function Clipboard()
    hs.eventtap.keyStroke({ "cmd" }, "space", 0)
    hs.timer.doAfter(0.1, function()
        hs.eventtap.keyStroke({ "cmd" }, "4", 0)
    end)
end

hs.hotkey.bind({ "alt" }, "v", function()
    Clipboard()
end)
