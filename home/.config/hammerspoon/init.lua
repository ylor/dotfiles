---@diagnostic disable-next-line: undefined-global
local hs        = hs

mod             = {}
mod.main        = { "alt" }
mod.cmd         = { "cmd" }
mod.hyper       = { "ctrl", "alt", "cmd" }
mod.combined    = { "ctrl", "alt" }
mod.hyper.shift = { "ctrl", "alt", "cmd", "shift" }
mod.main.shift  = { "alt", "shift" }

require('lib.watchers')
require("lib.macos")
require("lib.app")
require("lib.finder")
require("lib.mouse")
require("lib.space")
require("lib.window")
-- require("lib.reload")

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
    App(mod.main, "S", "Slack")
else
    App(mod.main, "I", "Safari")
    App(mod.main.shift, "I", "Zen")
end

hs.hotkey.bind(mod.hyper, "o", function() RunCommand("trex") end)
hs.hotkey.bind(mod.hyper.shift, "o", function() RunCommand("ocr") end)

hs.hotkey.bind(mod.combined, "left", function() Focus("left") end)
hs.hotkey.bind(mod.combined, "down", function() Focus("down") end)
hs.hotkey.bind(mod.combined, "up", function() Focus("up") end)
hs.hotkey.bind(mod.combined, "right", function() Focus("right") end)

hs.hotkey.bind(mod.hyper, "down", WindowFloat)
hs.hotkey.bind(mod.hyper, "left", function()
    local win = hs.window.focusedWindow()
    local westScreen = win:screen():toWest()
    if not westScreen then return end
    SelectMenuItem({ "Window", "Move to " .. westScreen:name() })
end)

hs.hotkey.bind(mod.hyper, "right", function()
    local win = hs.window.focusedWindow()
    local eastScreen = win:screen():toEast()
    if not eastScreen then return end
    SelectMenuItem({ "Window", "Move to " .. eastScreen:name() })
end)

hs.hotkey.bind(mod.hyper, "R", hs.reload)
hs.alert.show("Config loaded")
