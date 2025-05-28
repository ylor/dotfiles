---@diagnostic disable-next-line: undefined-global
local hs         = hs

--Key Hierarchy
---Spaces = Control
---Global = Hyper
---Windows = Hyper

local mod        = {}
mod.hyper        = { "ctrl", "alt", "cmd" }
mod.hyper.shift  = { "ctrl", "alt", "cmd", "shift" }
mod.main         = { "ctrl" }
mod.main.shift   = { table.unpack(mod.main), "shift" }
mod.second       = { "alt" }
mod.second.shift = { table.unpack(mod.second), "shift" }

function App(mods, key, app)
    hs.hotkey.bind(mods, key, function()
        hs.application.launchOrFocus(app)
        Focus()
    end)
end

App("cmd", "Return", "Ghostty")
App(mod.main, "Return", "Ghostty")
App(mod.hyper, "Return", "Ghostty")
App(mod.main, "E", "Zed")
App(mod.main, "F", "Finder")
App(mod.main, "P", "1Password")
App(mod.main, "T", "Ghostty")

local work = string.find(hs.host.localizedName(), "^PAPA-")
if work then
    App(mod.main, "I", "Arc")
    App(mod.main, "O", "Safari")
else
    App(mod.main, "I", "Safari")
    App(mod.main, "O", "Zen")
end

function Focus(method)
    if method == "left" then
        hs.window.focusedWindow():focusWindowWest()
    elseif method == "down" then
        hs.window.focusedWindow():focusWindowSouth()
    elseif method == "up" then
        hs.window.focusedWindow():focusWindowNorth()
    elseif method == "right" then
        hs.window.focusedWindow():focusWindowEast()
    end

    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local center = hs.geometry.rectMidPoint(frame)
    hs.mouse.absolutePosition(center)
end

hs.hotkey.bind(mod.hyper.shift, "h", function()
    Focus("left")
end)
hs.hotkey.bind(mod.hyper.shift, "j", function()
    Focus("down")
end)
hs.hotkey.bind(mod.hyper.shift, "k", function()
    Focus("up")
end)
hs.hotkey.bind(mod.hyper.shift, "l", function()
    Focus("right")
end)

hs.hotkey.bind(mod.hyper.shift, "Left", function()
    Focus("left")
end)

hs.hotkey.bind(mod.hyper.shift, "Right", function()
    Focus("right")
end)

hs.hotkey.bind(mod.hyper, 'down', function()
    local app = hs.application.frontmostApplication()
    app:selectMenuItem({ "Window", "Center" })
end)
hs.hotkey.bind(mod.hyper, 'up', function()
    local app = hs.application.frontmostApplication()
    app:selectMenuItem({ "Window", "Fill" })
end)

hs.hotkey.bind(mod.hyper, 'left', function()
    local app = hs.application.frontmostApplication()
    app:selectMenuItem({ "Window", "Move & Resize", "Left" })
end)
hs.hotkey.bind(mod.hyper, 'right', function()
    local app = hs.application.frontmostApplication()
    app:selectMenuItem({ "Window", "Move & Resize", "Right" })
end)


hs.hotkey.bind(mod.hyper, "c", function()
    local win = hs.window.focusedWindow()
    local frame = win:screen():frame()

    -- size
    local w = frame.w / 1.5
    local h = frame.h / 1.25

    -- position
    local x = frame.x + (frame.w - w) / 2
    local y = frame.y + (frame.h - h) / 2

    win:setFrame(hs.geometry.rect(x, y, w, h), 0)
end)

hs.hotkey.bind(mod.main.shift, "left", function()
    local app = hs.application.frontmostApplication()
    local win = hs.window.focusedWindow()
    local westScreen = win:screen():toWest()
    -- win:moveToScreen(westScreen)
    app:selectMenuItem({ "Window", "Move to " .. westScreen:name() })
end)

hs.hotkey.bind(mod.main.shift, "right", function()
    local app = hs.application.frontmostApplication()
    local win = hs.window.focusedWindow()
    local eastScreen = win:screen():toEast()
    -- win:moveToScreen(eastScreen)
    app:selectMenuItem({ "Window", "Move to " .. eastScreen })
end)

-- hs.hotkey.bind(mod.hyper, "L", hs.caffeinate.lockScreen)
-- hs.hotkey.bind(mod.hyperShift, "L", hs.caffeinate.systemSleep)
hs.hotkey.bind(mod.hyper, "R", hs.reload)
hs.alert.show("Config loaded")
