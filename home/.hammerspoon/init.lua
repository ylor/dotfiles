hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "C", function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local frame = screen:frame()

    -- Calculate half width and half height
    local newWidth = frame.w / 2
    local newHeight = frame.h / 2

    -- Calculate centered position
    local newX = frame.x + (frame.w - newWidth) / 2
    local newY = frame.y + (frame.h - newHeight) / 2

    -- Set window frame
    win:setFrame(hs.geometry.rect(newX, newY, newWidth, newHeight))
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Return", function()
    hs.application.launchOrFocus("Ghostty")
end)
hs.hotkey.bind("ctrl", "Return", function()
    hs.application.launchOrFocus("Ghostty")
end)

hs.hotkey.bind("ctrl", "F", function()
    hs.application.launchOrFocus("Finder")
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
    hs.reload()
end)
hs.alert.show("Config loaded")
