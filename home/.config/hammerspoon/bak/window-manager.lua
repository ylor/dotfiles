---@diagnostic disable-next-line: undefined-global
local hs = hs

-- middle left
hs.hotkey.bind(Mod.main, "Left", function()
    hs.window.focusedWindow():moveToUnit({ 0, 0, 0.5, 1 })
end)

-- middle right
hs.hotkey.bind(Mod.main, "Right", function()
    hs.window.focusedWindow():moveToUnit({ 0.5, 0, 0.5, 1 })
end)

-- middle up
hs.hotkey.bind(Mod.main.shift, "Up", function()
    hs.window.focusedWindow():moveToUnit({ 0, 0, 1, 0.5 })
end)

-- middle down
hs.hotkey.bind(Mod.main.shift, "Down", function()
    hs.window.focusedWindow():moveToUnit({ 0, 0.5, 1, 0.5 })
end)

-- maximize
hs.hotkey.bind(Mod.main, "Up", function()
    hs.window.focusedWindow():moveToUnit({ 0, 0, 1, 1 })
end)

-- centralize at 80% screen size
hs.hotkey.bind(Mod.main, "Down", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local max = win:screen():frame()

    f.x = max.x * 0.8
    f.y = max.y * 0.8
    f.w = max.w * 0.8
    f.h = max.h * 0.8

    win:setFrame(f)
    win:centerOnScreen()
end)
