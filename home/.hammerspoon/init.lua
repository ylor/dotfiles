---@diagnostic disable-next-line: undefined-global
local hs = hs

--Key Hierarchy
---Spaces = Control
---Global = Control
---Windows = Hyper
---Modifier = Shift

Hyper = { "cmd", "alt", "ctrl" }
HyperShift = { "cmd", "alt", "ctrl", "shift" }

Hostname = hs.host.localizedName()
Work = string.find(Hostname, "^PAPA-")

function App(mods, key, app)
    hs.hotkey.bind(mods, key, function()
        hs.application.launchOrFocus(app)
    end)
end

function FocusMouse()
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local center = hs.geometry.rectMidPoint(frame)
    hs.mouse.setAbsolutePosition(center)
end

App(Hyper, "Return", "Ghostty")
App("cmd", "Return", "Ghostty")
App("ctrl", "E", "Zed")
App("ctrl", "F", "Finder")
App("ctrl", "P", "1Password")
App("ctrl", "T", "Ghostty")

if Work then
    App("ctrl", "I", "Arc")
    App("ctrl", "O", "Safari")
else
    App("ctrl", "I", "Safari")
    App("ctrl", "O", "Zen")
end

hs.hotkey.bind(HyperShift, "down", function()
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    local frame = screen:frame()

    -- size
    local w = frame.w / 1.5
    local h = frame.h * 0.95

    -- position
    local x = frame.x + (frame.w - w) / 2
    local y = frame.y + (frame.h - h) / 2

    win:setFrameWithWorkarounds(hs.geometry.rect(x, y, w, h), 0)
end)

hs.hotkey.bind({ "ctrl", "shift" }, "left", function()
    local win = hs.window.focusedWindow()
    local westScreen = win:screen():toWest()
    win:moveToScreen(westScreen)
end)

hs.hotkey.bind({ "ctrl", "shift" }, "right", function()
    local win = hs.window.focusedWindow()
    local eastScreen = win:screen():toEast()
    win:moveToScreen(eastScreen)
end)

hs.hotkey.bind(HyperShift, "Left", function()
    hs.window.focusedWindow():focusWindowWest()
end)

hs.hotkey.bind(HyperShift, "Right", function()
    hs.window.focusedWindow():focusWindowEast()
end)

hs.hotkey.bind(Hyper, "L", hs.caffeinate.lockScreen)
hs.hotkey.bind(Hyper, "S", hs.caffeinate.systemSleep)
hs.hotkey.bind(Hyper, "R", hs.reload)

hs.alert.show("Config loaded")
