---@diagnostic disable-next-line: undefined-global
local hs = hs

require("lib.keymap")
require("lib.snippets")
require("lib.mouse")
require("lib.macos")
require("lib.app")
require("lib.window")
require("lib.space")
require("lib.quitter")

App(Mod.main, "E", "Zed")
App(Mod.main, "F", "Finder")
App(Mod.main, "I", "Safari")
App(Mod.main, "P", "1Password")
App(Mod.main, "Return", "Ghostty")
App(Mod.main, "T", "Ghostty")
App(Mod.main.shift, "I", "Helium")
App(Mod.main.shift, "T", "Terminal")

Tui(Mod.hyper, "P", "/opt/homebrew/bin/btop")

Web(Mod.main, "A", "https://chatgpt.com")
Web(Mod.main.shift, "A", "https://gemini.google.com")

Work = string.find(hs.host.localizedName(), "^PAPA")

if Work then
    App(Mod.main, "I", "Arc")
    App(Mod.main.shift, "I", "Safari")
    App(Mod.main, "S", "Slack")
else
end

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

hs.hotkey.bind(Mod.hyper, "o", function() RunCommand("ocr") end)
hs.hotkey.bind(Mod.main, ".", Unlock1Password)

-- Clipboard Manager
if not AppExists("Maccy") then
    hs.hotkey.bind({ "cmd", "shift" }, "v", function()
        hs.eventtap.keyStroke({ "cmd" }, "space", 0)
        hs.timer.doAfter(0.1, function()
            hs.eventtap.keyStroke({ "cmd" }, "4", 0)
        end)
    end)
end

hs.hotkey.bind(Mod.hyper, "\\", hs.reload)
hs.hotkey.bind(Mod.hyper, "R", hs.reload)
hs.alert.show("Config loaded")
