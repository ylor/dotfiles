---@diagnostic disable-next-line: undefined-global
local hs                    = hs
hs.window.animationDuration = 0.1

Mod                         = {}
Mod.main                    = { "option" }
-- Mod.main.shift = { "option", "shift" }
Mod.hyper                   = { "control", "option", "command" }
-- Mod.hyper.shift = { "control", "option", "command", "shift" }
-- Mod.win = { "control" }
-- Mod.win.shift  = { "control", "shift" }

Work                        = string.find(hs.host.localizedName(), "^PAPA")

require("lib.apps")
require("lib.spaces")
require("lib.window")
require("lib.input")
require("lib.app.modals")
require("lib.menubar.spaces")
-- require("lib.menubar.windows")
require("lib.expander")
require("lib.quitter")
require("lib.tabber")

hs.hotkey.bind(Mod.main, ".", App("1Password"))
hs.hotkey.bind(Mod.main, "\\", App("Zed"))
hs.hotkey.bind(Mod.main, "E", App("Finder"))
hs.hotkey.bind(Mod.main, "G", App("Moonlight"))
-- hs.hotkey.bind(Mod.main, "I", App("Safari"))
hs.hotkey.bind(Mod.main, "I", App("Dia"))
-- hs.hotkey.bind(Mod.main, "O", App("Helium"))
hs.hotkey.bind(Mod.main, "P", App("1Password"))
hs.hotkey.bind(Mod.main, "Return", App("Ghostty"))

hs.hotkey.bind(Mod.hyper, ",", App("System Settings"))

if AppExists("/Applications/Claude.app") then
    hs.hotkey.bind(Mod.main, "A", App("Claude"))
else
    hs.hotkey.bind(Mod.main, "A", Web("https://claude.ai"))
end

if AppRunning("Safari")() then
    hs.hotkey.bind(Mod.main, "I", App("Safari"))
end

hs.hotkey.bind(Mod.main, "R", App("Screen Sharing"))
hs.hotkey.bind(Mod.hyper, "P", Tui("/opt/homebrew/bin/btop"))

hs.hotkey.bind(Mod.main, "F", WindowFillToggle)
hs.hotkey.bind(Mod.main, "V", ShowClipboard)
hs.hotkey.bind(Mod.main, "W", hs.spaces.toggleMissionControl)
hs.hotkey.bind({ "ctrl" }, "W", WindowCycleWidth)
hs.hotkey.bind(Mod.hyper, "D", hs.spaces.toggleShowDesktop)
hs.hotkey.bind(Mod.hyper, "H", AppZen)
hs.hotkey.bind(Mod.hyper, "L", hs.caffeinate.lockScreen)
hs.hotkey.bind(Mod.hyper, "up", WindowMaxi)
hs.hotkey.bind(Mod.hyper, "down", WindowMini)
hs.hotkey.bind(Mod.hyper, "left", MoveWindowLeftScreen)
hs.hotkey.bind(Mod.hyper, "right", MoveWindowRightScreen)

_G.WindowEventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, WindowArrowKeyHandler({
    [hs.keycodes.map.left]  = WindowLeft,
    [hs.keycodes.map.right] = WindowRight,
    [hs.keycodes.map.up]    = WindowFill,
    [hs.keycodes.map.down]  = WindowCenter,
})):start()

ChromeModal:bind({ "cmd", "shift" }, "c", CopyChromeTabURL)
FinderModal:bind({ "cmd" }, "l", FinderJumpToFolder)
HeliumModal:bind(Mod.main, "k", HeliumSelectAll)

for i = 1, 5 do
    hs.hotkey.bind({ "ctrl", "shift" }, tostring(i), function()
        MoveWindowToSpaceByDrag(i)
    end)
end

if Work then
    -- hs.hotkey.bind(Mod.main, "I", App("Google Chrome Dev"))
    -- hs.hotkey.bind(Mod.main, "O", App("Helium"))
    hs.hotkey.bind(Mod.main, "M", App("Mail"))
    hs.hotkey.bind(Mod.main, "S", App("Slack"))
    hs.hotkey.bind(Mod.hyper, "I", App("Island"))
    if AppExists("/Applications/Gemini.app") then
        hs.hotkey.bind(Mod.hyper, "A", App("Gemini"))
    else
        hs.hotkey.bind(Mod.hyper, "A", Web("https://gemini.google.com"))
    end
end

if not Work then
    hs.hotkey.bind(Mod.main, "M", App("Messages"))
    hs.hotkey.bind(Mod.hyper, "M", App("Mail"))
end

hs.hotkey.bind(Mod.hyper, "\\", hs.reload)
