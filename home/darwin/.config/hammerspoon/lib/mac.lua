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

function App(mods, key, app)
    hs.hotkey.bind(mods, key, function()
        AppCycler(app)
    end)
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

function AppZen()
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
            WindowMaxi()
        end)
    end)
end

function Run(mods, key, cmd)
    hs.hotkey.bind(mods, key, function()
        hs.execute(cmd)
    end)
end

function RunCommand(bin)
    local home = os.getenv("HOME")
    local cmd = home .. "/.local/bin/" .. bin
    hs.execute(hs.fs.symlinkAttributes(cmd).target)
end

function ShowClipboard()
    hs.eventtap.keyStroke({ "cmd" }, "space", 0)
    hs.timer.doAfter(0.02, function()
        hs.eventtap.keyStroke({ "cmd" }, "4", 0)
    end
    )
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
    local dragPos = { x = zoom.x + zoom.w + 5, y = zoom.y + (zoom.h / 2) }
    local savedPos = hs.mouse.absolutePosition()

    hs.mouse.absolutePosition(dragPos)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, dragPos):post()
    hs.timer.usleep(10000)
    hs.eventtap.keyStroke({ "ctrl" }, tostring(space), 0)
    hs.timer.usleep(10000)
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, dragPos):post()
    hs.timer.usleep(10000)
    hs.timer.doAfter(0.333, function() win:focus() end)
    -- hs.mouse.absolutePosition(savedPos)
end

_G.MouseScrollReverser = hs.eventtap.new({ hs.eventtap.event.types.scrollWheel }, function(e)
    local p = hs.eventtap.event.properties
    if e:getProperty(p.eventSourceStateID) ~= 1 then
        return false -- not real hardware input, leave it alone
    end
    if e:getProperty(p.scrollWheelEventIsContinuous) == 0 then
        e:setProperty(p.scrollWheelEventDeltaAxis1,
            -e:getProperty(p.scrollWheelEventDeltaAxis1))
    end
    return false
end):start()

require("lib.app.chrome")
require("lib.app.finder")
require("lib.app.helium")
require("lib.menubar.spaces")
-- require("lib.menubar.windows")
require("lib.expander")
require("lib.quitter")
require("lib.tabber")
require("lib.window")
