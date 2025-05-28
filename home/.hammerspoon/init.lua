---@diagnostic disable-next-line: undefined-global
local hs         = hs

--Key Hierarchy
---Spaces = Control
---Global = Hyper
---Windows = Hyper

local mod        = {}
mod.hyper        = { "ctrl", "alt", "cmd" }
mod.hyper.shift  = { "ctrl", "alt", "cmd", "shift" }
mod.main         = { "ctrl" }
mod.main.shift   = { "ctrl", "shift" }
mod.second       = { "alt" }
mod.second.shift = { "alt", "shift" }

function App(mods, key, app)
    hs.hotkey.bind(mods, key, function()
        hs.application.launchOrFocus(app)
        Focus()
    end)
end

App("cmd", "Return", "Ghostty")
App(mod.hyper, "Return", "Ghostty")
App(mod.main, "Return", "Ghostty")
App(mod.main, "E", "Zed")
App(mod.main, "F", "Finder")
App(mod.main, "P", "1Password")
App(mod.main, "T", "Ghostty")

local work = string.find(hs.host.localizedName(), "^PAPA-")
if work then
    App(mod.main, "I", "Arc")
    App(mod.main, "O", "Safari")
else
    App(mod.main, "I", "Safari")
    App(mod.main, "O", "Zen")
end

function Focus(direction)
    if direction == "left" then
        hs.window.focusedWindow():focusWindowWest()
    elseif direction == "down" then
        hs.window.focusedWindow():focusWindowSouth()
    elseif direction == "up" then
        hs.window.focusedWindow():focusWindowNorth()
    elseif direction == "right" then
        hs.window.focusedWindow():focusWindowEast()
    end

    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local center = hs.geometry.rectMidPoint(frame)
    hs.mouse.absolutePosition(center)
end

hs.hotkey.bind(mod.hyper.shift, "h", function() Focus("left") end)
hs.hotkey.bind(mod.hyper.shift, "j", function() Focus("down") end)
hs.hotkey.bind(mod.hyper.shift, "k", function() Focus("up") end)
hs.hotkey.bind(mod.hyper.shift, "l", function() Focus("right") end)

hs.hotkey.bind(mod.main.shift, "left", function() Focus("left") end)
hs.hotkey.bind(mod.main.shift, "right", function() Focus("right") end)


hs.hotkey.bind(mod.main.shift, "c", function()
    local win = hs.window.focusedWindow()
    local frame = win:screen():frame()

    -- size
    local w = frame.w / 1.5
    local h = frame.h / 1.25

    -- position
    local x = frame.x + (frame.w - w) / 2
    local y = frame.y + (frame.h - h) / 2

    win:setFrame(hs.geometry.rect(x, y, w, h), 0)
end)

hs.hotkey.bind(mod.main.shift, "left", function()
    local app = hs.application.frontmostApplication()
    local win = hs.window.focusedWindow()
    local westScreen = win:screen():toWest()
    -- win:moveToScreen(westScreen)
    app:selectMenuItem({ "Window", "Move to " .. westScreen:name() })
end)

hs.hotkey.bind(mod.main.shift, "right", function()
    local app = hs.application.frontmostApplication()
    local win = hs.window.focusedWindow()
    local eastScreen = win:screen():toEast()
    -- win:moveToScreen(eastScreen)
    app:selectMenuItem({ "Window", "Move to " .. eastScreen })
end)

local windowManager = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local app = hs.application.frontmostApplication()
    local flags = event:getFlags()
    local ctrl = flags:containExactly({ "ctrl" }) or flags:containExactly({ "ctrl", "fn" })
    local kc = event:getKeyCode()

    if ctrl and kc == hs.keycodes.map["left"] then
        app:selectMenuItem({ "Window", "Move & Resize", "Left" })
        return true
    elseif ctrl and kc == hs.keycodes.map["down"] then
        app:selectMenuItem({ "Window", "Center" })
        return true
    elseif ctrl and kc == hs.keycodes.map["up"] then
        app:selectMenuItem({ "Window", "Fill" })
        return true
    elseif ctrl and kc == hs.keycodes.map["right"] then
        app:selectMenuItem({ "Window", "Move & Resize", "Right" })
        return true
    end

    return false
end)
windowManager:start()

-- hs.hotkey.bind(mod.hyper, "L", hs.caffeinate.lockScreen)
-- hs.hotkey.bind(mod.hyperShift, "L", hs.caffeinate.systemSleep)
hs.hotkey.bind(mod.hyper, "R", hs.reload)
hs.alert.show("Config loaded")
