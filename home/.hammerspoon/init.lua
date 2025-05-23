-- function reloadConfig(files)
--     doReload = false
--     for _, file in pairs(files) do
--         if file:sub(-4) == ".lua" then
--             doReload = true
--         end
--     end
--     if doReload then
--         hs.reload()
--     end
-- end

-- myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
--     hs.reload()
-- end)

-- hs.alert.show("Config loaded")

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

-- Example usage: bind to hotkey
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Return", function()
    hs.application.launchOrFocus("Ghostty")
end)

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
