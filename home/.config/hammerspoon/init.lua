---@diagnostic disable-next-line: undefined-global
local hs = hs

require("lib.macos")
require("lib.app")
require("lib.finder")
require("lib.mouse")
require("lib.space")
require("lib.window")
-- require("lib.reload")

local mod       = {}
mod.alt         = { "alt" }
mod.main        = { "ctrl" }
mod.cmd         = { "cmd" }
mod.hyper       = { "ctrl", "alt", "cmd" }
mod.combined    = { "ctrl", "alt" }
mod.hyper.shift = { "ctrl", "alt", "cmd", "shift" }
mod.main.shift  = { "ctrl", "shift" }
mod.alt.shift   = { "alt", "shift" }

App(mod.main, "Return", "Ghostty")
App(mod.main, "E", "Zed")
App(mod.main, "F", "Finder")
App(mod.main, "P", "1Password")
App(mod.main, "T", "Ghostty")
App(mod.main.shift, "T", "Terminal")

local work = string.find(hs.host.localizedName(), "^PAPA-")
if work then
    App(mod.main, "I", "Arc")
    App(mod.main.shift, "I", "Safari")
else
    App(mod.main, "I", "Safari")
    App(mod.main.shift, "I", "Zen")
end

hs.hotkey.bind(mod.hyper, "o", function() RunCommand("trex") end)
hs.hotkey.bind(mod.hyper.shift, "o", function() RunCommand("ocr") end)
hs.hotkey.bind(mod.main, "w", WindowFill)
hs.hotkey.bind(mod.main, "a", WindowLeft)
hs.hotkey.bind(mod.main, "s", WindowCenter)
hs.hotkey.bind(mod.main, "d", WindowRight)
hs.hotkey.bind(mod.main.shift, "w", function() Focus("up") end)
hs.hotkey.bind(mod.main.shift, "a", function() Focus("left") end)
hs.hotkey.bind(mod.main.shift, "s", function() Focus("down") end)
hs.hotkey.bind(mod.main.shift, "d", function() Focus("right") end)

hs.hotkey.bind(mod.main, "h", WindowLeft)
hs.hotkey.bind(mod.main, "j", WindowCenter)
hs.hotkey.bind(mod.main, "k", WindowFill)
hs.hotkey.bind(mod.main, "l", WindowRight)
hs.hotkey.bind(mod.main.shift, "h", function() Focus("left") end)
hs.hotkey.bind(mod.main.shift, "j", function() Focus("down") end)
hs.hotkey.bind(mod.main.shift, "k", function() Focus("up") end)
hs.hotkey.bind(mod.main.shift, "l", function() Focus("right") end)

hs.hotkey.bind(mod.main, "left", WindowLeft)
hs.hotkey.bind(mod.main, "down", WindowCenter)
hs.hotkey.bind(mod.main, "up", WindowFill)
hs.hotkey.bind(mod.main, "right", WindowRight)
hs.hotkey.bind(mod.main.shift, "left", function() Focus("left") end)
hs.hotkey.bind(mod.main.shift, "down", function() Focus("down") end)
hs.hotkey.bind(mod.main.shift, "up", function() Focus("up") end)
hs.hotkey.bind(mod.main.shift, "right", function() Focus("right") end)

hs.hotkey.bind(mod.combined, "left", function() Focus("left") end)
hs.hotkey.bind(mod.combined, "down", function() Focus("down") end)
hs.hotkey.bind(mod.combined, "up", function() Focus("up") end)
hs.hotkey.bind(mod.combined, "right", function() Focus("right") end)

hs.hotkey.bind(mod.main.shift, "down", WindowFloat)
hs.hotkey.bind(mod.main.shift, "left", function()
    local win = hs.window.focusedWindow()
    local westScreen = win:screen():toWest()
    if not westScreen then return end
    SelectMenuItem({ "Window", "Move to " .. westScreen:name() })
end)

hs.hotkey.bind(mod.main.shift, "right", function()
    local win = hs.window.focusedWindow()
    local eastScreen = win:screen():toEast()
    if not eastScreen then return end
    SelectMenuItem({ "Window", "Move to " .. eastScreen:name() })
end)

if not AppRunning("Maccy") then
    hs.hotkey.bind(mod.hyper, "v", function()
        -- local spot = IsActiveWindowSpotlight()
        -- if spot then
        --     hs.eventtap.keyStroke({ "cmd" }, "4", 0)
        -- else
        hs.eventtap.keyStroke({ "cmd" }, "space", 0)
        hs.timer.doAfter(0.1, function()
            hs.eventtap.keyStroke({ "cmd" }, "4", 0)
        end)
    end)
end
-- end

hs.hotkey.bind(mod.hyper, "R", hs.reload)
hs.alert.show("Config loaded")
