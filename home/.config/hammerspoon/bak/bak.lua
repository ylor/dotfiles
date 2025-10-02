---@diagnostic disable-next-line: undefined-global
local hs        = hs

Mod             = {}
Mod.main        = { "alt" }
Mod.cmd         = { "cmd" }
Mod.hyper       = { "ctrl", "alt", "cmd" }
Mod.combined    = { "ctrl", "alt" }
Mod.hyper.shift = { "ctrl", "alt", "cmd", "shift" }
Mod.main.shift  = { "alt", "shift" }

require('lib.watchers')
require("lib.macos")
require("lib.app")
require("lib.finder")
require("lib.mouse")
require("lib.space")
require("lib.window")
-- require("lib.carlos")
-- require("lib.reload")

App(Mod.main, "Return", "Ghostty")
App(Mod.main, "E", "Zed")
App(Mod.main, "F", "Finder")
App(Mod.main, "P", "1Password")
App(Mod.main, "T", "Ghostty")
App(Mod.main.shift, "T", "Terminal")

local work = string.find(hs.host.localizedName(), "^PAPA-")
if work then
    App(Mod.main, "I", "Arc")
    App(Mod.main.shift, "I", "Safari")
    App(Mod.main, "S", "Slack")
else
    App(Mod.main, "I", "Safari")
    App(Mod.main.shift, "I", "Zen")
end

hs.hotkey.bind(Mod.hyper, "o", function() RunCommand("trex") end)
hs.hotkey.bind(Mod.hyper.shift, "o", function() RunCommand("ocr") end)

hs.hotkey.bind(Mod.combined, "left", function() Focus("left") end)
hs.hotkey.bind(Mod.combined, "down", function() Focus("down") end)
hs.hotkey.bind(Mod.combined, "up", function() Focus("up") end)
hs.hotkey.bind(Mod.combined, "right", function() Focus("right") end)

hs.hotkey.bind(Mod.hyper, "down", WindowFloat)
hs.hotkey.bind(Mod.hyper, "left", function()
    local win = hs.window.focusedWindow()
    local westScreen = win:screen():toWest()
    if not westScreen then return end
    SelectMenuItem({ "Window", "Move to " .. westScreen:name() })
end)

hs.hotkey.bind(Mod.hyper, "right", function()
    local win = hs.window.focusedWindow()
    local eastScreen = win:screen():toEast()
    if not eastScreen then return end
    SelectMenuItem({ "Window", "Move to " .. eastScreen:name() })
end)

hs.hotkey.bind(Mod.hyper, "R", hs.reload)
hs.alert.show("Config loaded")
