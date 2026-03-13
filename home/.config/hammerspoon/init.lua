---@diagnostic disable-next-line: undefined-global
local hs        = hs

Mod             = {}
Mod.main        = { "option" }
Mod.main.shift  = { "option", "shift" }
Mod.hyper       = { "control", "option", "command" }
Mod.hyper.shift = { "control", "option", "command", "shift" }

Work            = string.find(hs.host.localizedName(), "^PAPA")

require("lib.macos")
require("lib.app")
require("lib.scroll")
require("lib.space")
require("lib.snippets")
require("lib.window")
require("lib.quitter")

App(Mod.main, ",", "System Settings")
App(Mod.main, ".", "1Password")
App(Mod.main, "C", "Zed")
App(Mod.main, "E", "Finder")
App(Mod.main, "G", "Moonlight")
App(Mod.main, "I", "Safari")
App(Mod.main, "P", "1Password")
App(Mod.main, "Return", "Ghostty")
App(Mod.main, "T", "Ghostty")
App(Mod.main.shift, "I", "Helium")
App(Mod.main.shift, "Return", "Zed")
App(Mod.main.shift, "T", "Terminal")
Tui(Mod.hyper, "P", "/opt/homebrew/bin/btop")
Web(Mod.main, "A", "https://claude.ai")

if Work then
    App(Mod.main, "I", "Google Chrome Dev")
    App(Mod.main, "O", "Helium")
    App(Mod.main, "S", "Slack")
    Web(Mod.main, "A", "https://gemini.google.com")
    Web(Mod.main.shift, "A", "https://claude.ai")
end

hs.hotkey.bind(Mod.main, "D", hs.spaces.toggleShowDesktop)
hs.hotkey.bind(Mod.main, "F", hs.window.toggleFullscreen)
hs.hotkey.bind(Mod.main, "L", hs.caffeinate.lockScreen)
hs.hotkey.bind(Mod.main, "W", hs.spaces.toggleMissionControl)
hs.hotkey.bind(Mod.main, "V", hs.spotlight.showClipboard)

hs.hotkey.bind(Mod.hyper, "left", WindowLeftScreen)
hs.hotkey.bind(Mod.hyper, "right", WindowRightScreen)

hs.hotkey.bind(Mod.hyper, "\\", hs.reload)
hs.hotkey.bind(Mod.hyper, "R", hs.reload)
-- hs.alert.show("Config loaded")
