---@diagnostic disable-next-line: undefined-global
local hs                    = hs
hs.window.animationDuration = 0.1

Mod                         = {}
Mod.main                    = { "option" }
Mod.main.shift              = { "option", "shift" }
Mod.hyper                   = { "control", "option", "command" }
-- Mod.hyper.shift = { "control", "option", "command", "shift" }
Mod.win                     = { "control" }
-- Mod.win.shift  = { "control", "shift" }

Work                        = string.find(hs.host.localizedName(), "^PAPA")

require("lib.mac")

App(Mod.main, ".", "1Password")
App(Mod.main, "C", "Zed")
App(Mod.main, "E", "Finder")
App(Mod.main, "G", "Moonlight")
-- App(Mod.main, "I", "Safari")
App(Mod.main, "I", "Dia")
App(Mod.main, "M", "Mail")
App(Mod.main, "O", "Helium")
App(Mod.main, "P", "1Password")
App(Mod.main, "Return", "Ghostty")

App(Mod.hyper, ",", "System Settings")

if AppExists("/Applications/Claude.app") then
    Web(Mod.main, "A", "https://claude.ai")
else
    App(Mod.main, "A", "Claude")
end

App(Mod.main, "R", "Screen Sharing")
Tui(Mod.hyper, "P", "/opt/homebrew/bin/btop")

hs.hotkey.bind(Mod.main, "F", WindowFillToggle)
hs.hotkey.bind(Mod.main, "V", ShowClipboard)
hs.hotkey.bind(Mod.hyper, "D", hs.spaces.toggleShowDesktop)
hs.hotkey.bind(Mod.hyper, "H", AppZen)
hs.hotkey.bind(Mod.hyper, "L", hs.caffeinate.lockScreen)
hs.hotkey.bind(Mod.hyper, "up", WindowMaxi)
hs.hotkey.bind(Mod.hyper, "down", WindowMini)
hs.hotkey.bind(Mod.hyper, "left", MoveWindowLeftScreen)
hs.hotkey.bind(Mod.hyper, "right", MoveWindowRightScreen)
hs.hotkey.bind(Mod.hyper, "O", hs.spaces.toggleMissionControl)

for i = 1, 5 do
    hs.hotkey.bind({ "ctrl", "shift" }, tostring(i), function()
        MoveWindowToSpaceByDrag(i)
    end)
end

if Work then
    -- App(Mod.main, "I", "Google Chrome Dev")
    App(Mod.main, "O", "Helium")
    App(Mod.main, "S", "Slack")
    App(Mod.hyper, "I", "Island")
    -- Web(Mod.main, "A", "https://gemini.google.com")
    -- if AppExists("/Applications/Gemini.app") then
    --     Web(Mod.main, "A", "https://gemini.google.com")
    -- else
    --     App(Mod.main, "A", "Gemini")
    -- end
end

if not Work then
    App(Mod.main, "M", "Messages")
    App(Mod.hyper, "M", "Mail")
end

hs.hotkey.bind(Mod.hyper, "\\", hs.reload)
