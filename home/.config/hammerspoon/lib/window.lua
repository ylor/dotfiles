---@diagnostic disable-next-line: undefined-global
local hs = hs

local windowList = {}
local windowIndex = 0
local function cycleWindow()
    local windows = windowFilter:getWindows(hs.window.filter.sortByFocusedLast)
    if #windows <= 1 then return end

    local focusedWindow = hs.window.focusedWindow()
    local newCycle = not windowList or #windowList ~= #windows
    local newFocus = focusedWindow ~= windowList[windowIndex]

    if newCycle or newFocus then
        windowList = windows
        windowIndex = 1
    end

    windowIndex = (windowIndex % #windowList) + 1
    windowList[windowIndex]:focus()
end

local function handleKeyDown(event)
    local flags = event:getFlags()
    local kc = event:getKeyCode()
    local key = hs.keycodes.map

    local cmd = flags:containExactly({ "cmd" }) or flags:containExactly({ "cmd", "fn" })
    local ctrl = flags:containExactly({ "ctrl" }) or flags:containExactly({ "ctrl", "fn" })
    local alt = flags:containExactly({ "alt" }) or flags:containExactly({ "alt", "fn" })
    local hyper = flags:containExactly({ "ctrl", "alt", "cmd" }) or flags:containExactly({ "ctrl", "alt", "cmd", "fn" })

    if cmd and kc == key["tab"] then
        cycleWindow()
        return true
    end

    if cmd and kc == key["`"] then
        cycleWindow()
        return true
    end

    if alt and kc == key["tab"] then
        cycleWindow()
        return true
    end

    if ctrl and kc == hs.keycodes.map["left"] then
        WindowLeft()
    elseif ctrl and kc == hs.keycodes.map["down"] then
        WindowCenter()
    elseif ctrl and kc == hs.keycodes.map["up"] then
        WindowFill()
    elseif ctrl and kc == hs.keycodes.map["right"] then
        WindowRight()
    elseif hyper and kc == hs.keycodes.map["down"] then
        WindowFloat()
    else
        return false
    end

    return true
end

-- Global function to prevent garbage collection
EventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handleKeyDown)
EventTapper:start()

-- Responsive window switcher
-- Create a window filter for current screen and space
windowFilter = hs.window.filter.new():setCurrentSpace(true):setScreens(hs.screen.mainScreen():getUUID())

-- Update the screen filter to the main screen
screenWatcher = hs.screen.watcher.new(function()
    windowFilter:setScreens(hs.screen.mainScreen():getUUID())
end)
screenWatcher:start()

-- hs.hotkey.bind({ "alt" }, "tab", cycleWindow)
