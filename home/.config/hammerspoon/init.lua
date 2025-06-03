require("lib.app")
require("lib.mouse")
require("lib.window")
require("lib.macos")

---@diagnostic disable-next-line: undefined-global
local hs        = hs

--Key Hierarchy
---Spaces = Control
---Global = Hyper
---Windows = Hyper

local mod       = {}
mod.alt         = { "alt" }
mod.main        = { "ctrl" }
mod.hyper       = { "ctrl", "alt", "cmd" }
mod.combined    = { "ctrl", "alt" }
mod.hyper.shift = { "ctrl", "alt", "cmd", "shift" }
mod.main.shift  = { "ctrl", "shift" }
mod.alt.shift   = { "alt", "shift" }

App(mod.hyper, "Return", "Ghostty")
App(mod.main, "Return", "Ghostty")
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

function Focus(direction)
    if direction == "left" then
        hs.window.focusedWindow():focusWindowWest()
    elseif direction == "down" then
        hs.window.focusedWindow():focusWindowSouth()
    elseif direction == "up" then
        hs.window.focusedWindow():focusWindowNorth()
    elseif direction == "right" then
        hs.window.focusedWindow():focusWindowEast()
    end

    -- local win = hs.window.focusedWindow()
    -- local frame = win:frame()
    -- local center = hs.geometry.rectMidPoint(frame)
    -- hs.mouse.absolutePosition(center)
end

hs.hotkey.bind(mod.hyper, "h", function()
    hs.application.frontmostApplication():selectMenuItem({ "Window", "Move & Resize", "Left" })
end)
hs.hotkey.bind(mod.hyper, "j", function()
    hs.application.frontmostApplication():selectMenuItem({ "Window", "Center" })
end)
hs.hotkey.bind(mod.hyper, "k", function()
    hs.application.frontmostApplication():selectMenuItem({ "Window", "Fill" })
end)
hs.hotkey.bind(mod.hyper, "l", function()
    hs.application.frontmostApplication():selectMenuItem({ "Window", "Move & Resize", "Right" })
end)

hs.hotkey.bind(mod.hyper, "left", WindowLeft)
hs.hotkey.bind(mod.hyper, "down", WindowCenter)
hs.hotkey.bind(mod.hyper, "up", WindowFill)
hs.hotkey.bind(mod.hyper, "right", WindowRight)

hs.hotkey.bind(mod.hyper.shift, "h", function() Focus("left") end)
hs.hotkey.bind(mod.hyper.shift, "j", function() Focus("down") end)
hs.hotkey.bind(mod.hyper.shift, "k", function() Focus("up") end)
hs.hotkey.bind(mod.hyper.shift, "l", function() Focus("right") end)
hs.hotkey.bind(mod.hyper.shift, "left", function() Focus("left") end)
hs.hotkey.bind(mod.hyper.shift, "down", function() Focus("down") end)
hs.hotkey.bind(mod.hyper.shift, "up", function() Focus("up") end)
hs.hotkey.bind(mod.hyper.shift, "right", function() Focus("right") end)

hs.hotkey.bind(mod.combined, "left", function() Focus("left") end)
hs.hotkey.bind(mod.combined, "right", function() Focus("right") end)


hs.hotkey.bind(mod.main.shift, "c", function()
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
    app:selectMenuItem({ "Window", "Move to " .. eastScreen:name() })
end)

-- hs.hotkey.bind(mod.hyper, "L", hs.caffeinate.lockScreen)
--- hs.hotkey.bind(mod.hyperShift, "L", hs.caffeinate.systemSleep)
hs.hotkey.bind(mod.hyper, "R", hs.reload)
hs.alert.show("Config loaded")
