require("lib.app")
require("lib.mouse")
require("lib.window")
require("lib.macos")

---@diagnostic disable-next-line: undefined-global
local hs        = hs

local mod       = {}
mod.alt         = { "alt" }
mod.main        = { "ctrl" }
mod.hyper       = { "ctrl", "alt", "cmd" }
mod.combined    = { "ctrl", "alt" }
mod.hyper.shift = { "ctrl", "alt", "cmd", "shift" }
mod.main.shift  = { "ctrl", "shift" }
mod.alt.shift   = { "alt", "shift" }

App(mod.hyper, "Return", "Ghostty")
App(mod.hyper, "E", "Zed")
App(mod.hyper, "F", "Finder")
App(mod.hyper, "P", "1Password")
App(mod.hyper, "T", "Ghostty")

local work = string.find(hs.host.localizedName(), "^PAPA-")
if work then
    App(mod.hyper, "I", "Arc")
    App(mod.hyper, "O", "Safari")
else
    App(mod.hyper, "I", "Safari")
    App(mod.hyper, "O", "Zen")
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

hs.hotkey.bind(mod.hyper, "h", WindowLeft)
hs.hotkey.bind(mod.hyper, "j", WindowCenter)
hs.hotkey.bind(mod.hyper, "k", WindowFill)
hs.hotkey.bind(mod.hyper, "l", WindowRight)

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
    local win = hs.window.focusedWindow()
    local westScreen = win:screen():toWest()
    SelectMenuItem({ "Window", "Move to " .. westScreen:name() })
end)

hs.hotkey.bind(mod.main.shift, "right", function()
    local win = hs.window.focusedWindow()
    local eastScreen = win:screen():toEast()
    SelectMenuItem({ "Window", "Move to " .. eastScreen:name() })
end)

-- hs.hotkey.bind(mod.hyper, "L", hs.caffeinate.lockScreen)
-- hs.hotkey.bind(mod.hyperShift, "L", hs.caffeinate.systemSleep)
hs.hotkey.bind(mod.hyper, "R", hs.reload)
hs.alert.show("Config loaded")
