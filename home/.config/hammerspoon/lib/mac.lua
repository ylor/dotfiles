---@diagnostic disable-next-line: undefined-global
local hs = hs

hs.spotlight.showClipboard = function()
    hs.eventtap.keyStroke({ "cmd" }, "space", 0)
    hs.timer.doAfter(0.05, function()
        hs.eventtap.keyStroke({ "cmd" }, "4", 0)
    end)
end

function App(mods, key, app)
    hs.hotkey.bind(mods, key, function()
        AppHandler(app)
    end)
end

function Tui(mods, key, cmd)
    hs.hotkey.bind(mods, key, function()
        local terminal =
        "/usr/bin/open -na /Applications/Ghostty.app --args --confirm-close-surface=false --quit-after-last-window-closed=true --window-decoration=none --command="
        hs.execute(terminal .. cmd)
        hs.timer.doAfter(0.5, function()
            WindowFloat()
        end)
    end)
end

function Run(mods, key, cmd)
    hs.hotkey.bind(mods, key, function()
        hs.execute(cmd)
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

function RunCommand(bin)
    local home = os.getenv("HOME")
    local cmd = home .. "/.local/bin/" .. bin
    hs.execute(hs.fs.symlinkAttributes(cmd).target)
end
