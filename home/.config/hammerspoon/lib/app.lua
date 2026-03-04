---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Launch, focus or cycle through instances of an application
local lastApp = ""
local windowList = {}
local windowIndex = 0

local function AppHandler(appTitle)
    local app = hs.application.get(appTitle)

    if not app then
        hs.application.launchOrFocus(appTitle)
        return
    end

    local windows = {}
    for _, win in ipairs(app:allWindows()) do
        if win:isStandard() and win:screen() == hs.screen.primaryScreen() then
            table.insert(windows, win)
        end
    end

    -- 4. If no windows found, just activate the app
    if #windows == 0 then
        hs.application.launchOrFocus(appTitle)
        return
    end


    if lastApp ~= appTitle or #windows ~= #windowList then
        windowList = windows
        lastApp = appTitle
        windowIndex = 1
    else
        windowIndex = (windowIndex % #windows) + 1
    end

    -- 6. Direct focus (the fastest focus method)
    windowList[windowIndex]:focus()
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

function Clipboard()
    hs.eventtap.keyStroke({ "cmd" }, "space", 0)
    hs.timer.doAfter(0.1, function()
        hs.eventtap.keyStroke({ "cmd" }, "4", 0)
    end)
end

-- if not AppExists("Maccy") then
hs.hotkey.bind({ "cmd", "shift" }, "v", function()
    -- hs.eventtap.keyStroke({ "cmd" }, "space", 0)
    -- hs.timer.doAfter(0.1, function()
    --     hs.eventtap.keyStroke({ "cmd" }, "4", 0)
    -- end)
    Clipboard()
end)

hs.hotkey.bind({ "alt" }, "v", function()
    -- hs.eventtap.keyStroke({ "cmd" }, "space", 0)
    -- hs.timer.doAfter(0.1, function()
    --     hs.eventtap.keyStroke({ "cmd" }, "4", 0)
    -- end)
    Clipboard()
end)
