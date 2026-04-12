---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Focus or cycle an app's windows on the main screen
function AppHandler(app)
    local running = hs.application.find(app)
    if not running then return hs.application.launchOrFocus(app) end

    local wf = hs.window.filter.new(app)
        :setScreens(hs.screen.primaryScreen():getUUID())
    local windows = wf:getWindows(hs.window.filter.sortByLastFocused)

    -- app is running but there are no windows
    if #windows == 0 then return hs.application.launchOrFocus(app) end

    -- app is running but isn't current focus
    local focused = hs.window.focusedWindow()
    if not focused or focused:application():name() ~= app then
        return windows[1]:focus():centerMouse()
    end

    -- otherwise cycle to the next window
    for i, w in ipairs(windows) do
        if w:id() == focused:id() then
            return windows[(i % #windows) + 1]:focus():centerMouse()
        end
    end
end

function App(mods, key, app)
    hs.hotkey.bind(mods, key, function()
        AppHandler(app)
    end)
end

function AppFocus()
    local screen = hs.screen.mainScreen()
    local focused = hs.window.focusedWindow()
    local visible = hs.fnutils.filter(hs.window.visibleWindows(), function(w) return w:screen() == screen end)

    if #visible > 1 and focused then
        local focusedApp = focused:application()
        local hidden = {}
        for _, win in ipairs(visible) do
            if win ~= focused then
                local app = win:application()
                if app == focusedApp then
                    win:minimize()
                elseif not hidden[app] then
                    app:hide()
                    hidden[app] = true
                end
            end
        end
    else
        for _, app in ipairs(hs.application.runningApplications()) do
            if app:isHidden() then app:unhide() end
        end
        for _, win in ipairs(hs.window.minimizedWindows()) do
            win:unminimize()
        end
        focused:focus()
    end
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

function SpaceInfo()
    local spaces = hs.spaces.spacesForScreen("Primary")
    local active = hs.spaces.activeSpaceOnScreen("Primary")
    return hs.fnutils.indexOf(spaces, active), #spaces
end

function MoveWindowToSpaceByDrag(space)
    local currentSpace = SpaceInfo()
    if space == currentSpace then return end

    local win = hs.window.focusedWindow()
    if not win then return end

    local zoom = win:zoomButtonRect()
    local dragPos = { x = zoom.x + zoom.w + 2, y = zoom.y + (zoom.h / 2) + 10 }
    local savedPos = hs.mouse.absolutePosition()

    hs.mouse.absolutePosition(dragPos)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, dragPos):post()
    hs.timer.usleep(10000)
    hs.eventtap.keyStroke({ "ctrl" }, tostring(space), 0)
    hs.timer.usleep(10000)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, dragPos):post()
    hs.timer.doAfter(0.333, function() win:focus() end)
    hs.mouse.absolutePosition(savedPos)
end

function RunCommand(bin)
    local home = os.getenv("HOME")
    local cmd = home .. "/.local/bin/" .. bin
    hs.execute(hs.fs.symlinkAttributes(cmd).target)
end

require("lib.app.chrome")
require("lib.app.clipboard")
require("lib.app.finder")
require("lib.app.helium")
require("lib.menu.spaces")
require("lib.menu.windows")
require("lib.quitter")
require("lib.scroll")
require("lib.snippets")
require("lib.window")
require("lib.window.cycler")
require("lib.window.switcher")
