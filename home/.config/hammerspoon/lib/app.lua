---@diagnostic disable-next-line: undefined-global
local hs = hs

require("lib.app.finder")

local function AppHandler(app)
    local target = hs.application.get(app)
    local focusedWin = hs.window.focusedWindow()
    local windows = {}

    if target then
        for _, win in ipairs(target:allWindows()) do
            if win:isStandard() and win:isVisible() and win:screen() == hs.screen.mainScreen() then
                windows[#windows + 1] = win
            end
        end
    end

    if #windows == 0 then
        hs.application.launchOrFocus(app)
        return
    end

    -- bring its most recent window forward
    if not focusedWin or focusedWin:application():name() ~= app then
        windows[1]:focus()
        return
    end

    -- sort by id for stable cycling
    table.sort(windows, function(a, b) return a:id() < b:id() end)
    local currentIndex = 1
    for i, win in ipairs(windows) do
        if win:id() == focusedWin:id() then
            currentIndex = i
            break
        end
    end
    windows[(currentIndex % #windows) + 1]:focus()
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
