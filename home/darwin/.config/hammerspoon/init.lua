---@diagnostic disable-next-line: undefined-global
local hs = hs
-- Cap AX calls for all of Hammerspoon so a hung app can't block it for the
-- 6s default. Set first so the window filters' startup scans are capped too.
hs.axuielement.systemWideElement():setTimeout(0.25)
hs.window.animationDuration = 0.1
-- Lets the `hs` CLI talk to this instance.
require("hs.ipc")

Mod = {}
Mod.main = { "option" }
-- Mod.main.shift = { "option", "shift" }
Mod.hyper = { "control", "option", "command" }
-- Mod.hyper.shift = { "control", "option", "command", "shift" }
-- Mod.win = { "control" }
-- Mod.win.shift  = { "control", "shift" }

Work = string.find(hs.host.localizedName(), "^PAPA")

require("lib.apps")
require("lib.spaces")
require("lib.window")
require("lib.input")
require("lib.app.modals")
require("lib.menubar.spaces")

-- Temporary: on macOS 27 Golden Gate the ctrl+[1-5] space switching shortcuts
-- break on login and after an unlock. The Dock owns Mission Control, so
-- restarting it brings them back. Closest public report of the regression:
-- https://github.com/ruittenb/Spaceman/issues/46
-- Drop this once the bug is fixed.
local function restartDock()
	hs.task.new("/usr/bin/killall", nil, { "Dock" }):start()
end
-- After hs.spaces has loaded, because it crashes on load while the Dock is down.
restartDock()
_G.DockRestartWatcher = hs.caffeinate.watcher
	.new(function(event)
		if event == hs.caffeinate.watcher.screensDidUnlock then
			restartDock()
		end
	end)
	:start()

-- require("lib.menubar.windows")
require("lib.expander")
require("lib.quitter")
require("lib.tabber")
require("lib.focus")

hs.hotkey.bind(Mod.main, ".", App("1Password"))
-- hs.hotkey.bind(Mod.main, "\\", App("Zed"))
hs.hotkey.bind(Mod.main, "E", App("Finder"))
hs.hotkey.bind(Mod.main, "G", App("Moonlight"))
hs.hotkey.bind(Mod.main, "I", DefaultApp("http"))
-- hs.hotkey.bind(Mod.main, "I", function()
-- 	AppCycler(AppRunning("Safari") and "Safari" or "Dia")
-- end)
-- hs.hotkey.bind(Mod.main, "O", App("Helium"))
hs.hotkey.bind(Mod.main, "P", App("1Password"))
hs.hotkey.bind(Mod.main, "Return", App(Terminal))

hs.hotkey.bind(Mod.hyper, ",", App("System Settings"))

hs.hotkey.bind(Mod.main, "A", AppOrWeb("Claude", "https://claude.ai"))

hs.hotkey.bind(Mod.main, "R", App("Screen Sharing"))
hs.hotkey.bind(Mod.hyper, "P", Tui("/opt/homebrew/bin/btop"))

hs.hotkey.bind(Mod.main, "F", WindowFillToggle)
hs.hotkey.bind(Mod.main, "V", ShowClipboard)
hs.hotkey.bind(Mod.main, "W", hs.spaces.toggleMissionControl)
hs.hotkey.bind({ "ctrl" }, "W", WindowCycleWidth)
hs.hotkey.bind(Mod.hyper, "D", hs.spaces.toggleShowDesktop)
hs.hotkey.bind(Mod.hyper, "F", FocusFollowsMouseToggle)
hs.hotkey.bind(Mod.hyper, "H", AppZen)
hs.hotkey.bind(Mod.hyper, "I", ToggleMonitorInput)
hs.hotkey.bind(Mod.hyper, "L", hs.caffeinate.lockScreen)
hs.hotkey.bind(Mod.hyper, "O", function()
	hs.task.new(os.getenv("HOME") .. "/.local/bin/ocr", nil):start()
end)
hs.hotkey.bind(Mod.hyper, "up", WindowMaxi)
hs.hotkey.bind(Mod.hyper, "down", WindowMini)
hs.hotkey.bind(Mod.hyper, "left", MoveWindowLeftScreen)
hs.hotkey.bind(Mod.hyper, "right", MoveWindowRightScreen)

_G.WindowEventTapper = hs.eventtap
	.new(
		{ hs.eventtap.event.types.keyDown },
		WindowArrowKeyHandler({
			[hs.keycodes.map.left] = WindowLeft,
			[hs.keycodes.map.right] = WindowRight,
			[hs.keycodes.map.up] = WindowFill,
			[hs.keycodes.map.down] = WindowCenter,
		})
	)
	:start()

ChromeModal:bind({ "cmd", "shift" }, "c", CopyChromeTabURL)
ChromeModal:bind({ "cmd" }, "t", ChromeNewTabBelow)
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
	-- hs.hotkey.bind(Mod.hyper, "I", App("Island"))
	hs.hotkey.bind(Mod.hyper, "A", AppOrWeb("Gemini", "https://gemini.google.com"))
else
	hs.hotkey.bind(Mod.main, "M", App("Messages"))
	hs.hotkey.bind(Mod.hyper, "M", App("Mail"))
end

hs.hotkey.bind(Mod.hyper, "\\", hs.reload)
