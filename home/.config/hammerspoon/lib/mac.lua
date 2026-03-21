---@diagnostic disable-next-line: undefined-global
local hs = hs

function AppHandler(app)
  local focused = hs.window.focusedWindow()
  local running = hs.application.find(app)

  if not running then return hs.application.launchOrFocus(app) end

  local windows = hs.fnutils.filter(running:allWindows(), function(w)
    return w:isStandard() and w:screen() == hs.screen.mainScreen()
  end)

  if #windows == 0 then return hs.application.launchOrFocus(app) end

  table.sort(windows, function(a, b) return a:id() < b:id() end)

  local target = windows[1]

  if focused and focused:application():name() == app and #windows > 1 then
    for i, w in ipairs(windows) do
      if w:id() == focused:id() then
        target = windows[i % #windows + 1]
        break
      end
    end
  end

  target:focus():centerMouse()
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

function SpaceInfo()
    local spaces = hs.spaces.spacesForScreen("Main")
    local active = hs.spaces.activeSpaceOnScreen("Main")
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
require("lib.menu.spaces")
require("lib.menu.windows")
require("lib.quitter")
require("lib.scroll")
require("lib.snippets")
require("lib.window")
require("lib.window.switcher")
