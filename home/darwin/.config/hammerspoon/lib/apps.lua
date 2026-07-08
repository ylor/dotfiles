local hs = hs ---@diagnostic disable-line: undefined-global

-- Focus or cycle an app's windows on the main screen
function AppCycler(app)
    -- if not hs.application.find(app) then return end
    local primary = hs.screen.primaryScreen()
    local primaryUUID = primary:getUUID()

    local windows = hs.fnutils.filter(
        hs.window.filter.new(app):getWindows(hs.window.filter.sortByLastFocused),
        function(w) return w:screen():getUUID() == primaryUUID end
    )

    if #windows == 0 then return hs.application.launchOrFocus(app) end

    local focused = hs.window.focusedWindow()
    local idx = focused and hs.fnutils.indexOf(windows, focused) or 0
    local win = windows[idx % #windows + 1]

    win:focus():centerMouse()
end

function App(app)
    return function() AppCycler(app) end
end

function AppExists(app)
    if not string.match(app, "^/") then
        app = "/Applications/" .. app .. ".app"
    end
    return hs.application.infoForBundlePath(app) ~= nil
end

function AppRunning(appName)
    return function()
        local app = hs.application.find(appName)
        return app ~= nil and app:isRunning()
    end
end

function Tui(cmd)
    return function()
        local terminal =
        "/usr/bin/open -na /Applications/Ghostty.app --args --confirm-close-surface=false --quit-after-last-window-closed=true --window-decoration=none --command="
        hs.execute(terminal .. cmd)
        hs.timer.doAfter(0.5, function()
            WindowMaxi()
        end)
    end
end

function Web(url)
    return function()
        hs.execute("open " .. url)
    end
end

-- unused, kept for ad hoc use from the Hammerspoon console
-- function Run(mods, key, cmd)
--     hs.hotkey.bind(mods, key, function()
--         hs.execute(cmd)
--     end)
-- end

-- unused, kept for ad hoc use from the Hammerspoon console
-- function RunCommand(bin)
--     local home = os.getenv("HOME")
--     local cmd = home .. "/.local/bin/" .. bin
--     hs.execute(hs.fs.symlinkAttributes(cmd).target)
-- end

-- Keep watchers referenced so they aren't garbage collected.
local watchers = {}

-- A hotkey.modal scoped to one or more app names: entered while the app is
-- frontmost, exited otherwise. Bind keys on the returned modal from
-- init.lua; onEnter/onExit fire alongside modal:enter()/:exit() for any
-- extra app-scoped side effects (e.g. toggling another eventtap).
function AppModal(names, onEnter, onExit)
    local set = {}
    for _, n in ipairs(type(names) == "table" and names or { names }) do set[n] = true end

    local modal = hs.hotkey.modal.new()
    local watcher = hs.application.watcher.new(function(name, eventType)
        if not set[name] then return end

        if eventType == hs.application.watcher.activated then
            modal:enter()
            if onEnter then onEnter() end
        elseif eventType == hs.application.watcher.deactivated then
            modal:exit()
            if onExit then onExit() end
        end
    end):start()
    watchers[#watchers + 1] = watcher

    return modal
end
