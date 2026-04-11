---@diagnostic disable-next-line: undefined-global
local hs        = hs

Mod             = {}
Mod.main        = { "option" }
Mod.main.shift  = { "option", "shift" }
Mod.hyper       = { "control", "option", "command" }
Mod.hyper.shift = { "control", "option", "command", "shift" }
Work            = string.find(hs.host.localizedName(), "^PAPA")

require("lib.mac")

App(Mod.main, ",", "System Settings")
App(Mod.main, ".", "1Password")
App(Mod.main, "C", "Zed")
App(Mod.main, "E", "Finder")
App(Mod.main, "G", "Moonlight")
App(Mod.main, "I", "Safari")
App(Mod.main, "M", "Mail")
App(Mod.main, "O", "Helium")
App(Mod.main, "P", "1Password")
App(Mod.main, "Return", "Ghostty")
Web(Mod.main, "A", "https://claude.ai")
Run(Mod.main, "R", "open vnc://10.0.1.2")
Tui(Mod.hyper, "P", "/opt/homebrew/bin/btop")

if Work then
    App(Mod.main, "I", "Google Chrome Dev")
    App(Mod.main, "O", "Helium")
    App(Mod.main, "S", "Slack")
    Web(Mod.main, "A", "https://gemini.google.com")
end

hs.hotkey.bind(Mod.main, "W", hs.spaces.toggleMissionControl)
hs.hotkey.bind(Mod.main, "V", hs.spotlight.showClipboard)

hs.hotkey.bind(Mod.hyper, "D", hs.spaces.toggleShowDesktop)
hs.hotkey.bind(Mod.hyper, "F", hs.window.toggleFullscreen)
hs.hotkey.bind(Mod.hyper, "H", AppFocus)
hs.hotkey.bind(Mod.hyper, "L", hs.caffeinate.lockScreen)

hs.hotkey.bind(Mod.hyper, "down", WindowFloat)
hs.hotkey.bind(Mod.hyper, "left", WindowLeftScreen)
hs.hotkey.bind(Mod.hyper, "right", WindowRightScreen)

hs.hotkey.bind(Mod.hyper, "\\", hs.reload)
hs.hotkey.bind(Mod.hyper, "R", hs.reload)

for i = 1, 5 do
    hs.hotkey.bind({ "ctrl", "shift" }, tostring(i), function()
        MoveWindowToSpaceByDrag(i)
    end)
end

-- hs.alert.show("Config loaded")
