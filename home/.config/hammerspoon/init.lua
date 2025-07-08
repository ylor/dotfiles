require("lib.app")
require("lib.mouse")
require("lib.window")
require("lib.macos")
-- require("lib.reload")

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
App(mod.hyper.shift, "T", "Terminal")

local work = string.find(hs.host.localizedName(), "^PAPA-")
if work then
    App(mod.hyper, "I", "Arc")
    App(mod.hyper.shift, "I", "Safari")
else
    App(mod.hyper, "I", "Safari")
    App(mod.hyper.shift, "I", "Zen")
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


hs.hotkey.bind(mod.main.shift, "down", WindowFloat)
hs.hotkey.bind(mod.hyper, "o", ExtractText)

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

-- Get macOS version
OperatingSystem = hs.host.operatingSystemVersion().major

function IsActiveWindowSpotlight()
    local focusedWindow = hs.window.focusedWindow()

    if focusedWindow then
        local app = focusedWindow:application()
        if app:bundleID() == "com.apple.Spotlight" then
            return true
        end
    end
    return false
end

function AppExists(path)
    local attr = hs.fs.attributes(path)
    return attr and attr.mode == "directory"
end

AppExists("/Applications/Ghostty.app")

if OperatingSystem >= 16 then
    hs.alert.show("macOS " .. OperatingSystem)
    if not AppExists("/Applications/Maccy.app") then
        hs.hotkey.bind(mod.hyper, "v", function()
            local spot = IsActiveWindowSpotlight()
            if spot then
                hs.eventtap.keyStroke({ "cmd" }, "4", 0)
            else
                hs.eventtap.keyStroke({ "cmd" }, "space", 0)
                hs.timer.doAfter(0.1, function()
                    hs.eventtap.keyStroke({ "cmd" }, "4", 0)
                end)
            end
        end)
    end
end
