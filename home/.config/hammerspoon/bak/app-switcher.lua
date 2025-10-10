-- Cycle through apps on current screen and space
-- Bind to your preferred hotkey (e.g., Alt+Tab)

-- Create a window filter for current screen and space
local wf = hs.window.filter.new():setCurrentSpace(true):setScreens(hs.screen.mainScreen():getUUID())

local function updateScreenFilter()
    wf:setScreens(hs.screen.mainScreen():getUUID())
end

-- Update filter when screens change
local screenWatcher = hs.screen.watcher.new(updateScreenFilter)
screenWatcher:start()

local windowList
local cycleIndex = 0

local function cycleApps()
    local windows = wf:getWindows(hs.window.filter.sortByFocusedLast)

    if #windows <= 1 then
        return
    end

    -- Check if this is a new cycle (window list changed or focus broke the cycle)
    local focused = hs.window.focusedWindow()
    local continuesCycle = windowList and #windowList == #windows

    if continuesCycle and windowList[cycleIndex] then
        continuesCycle = (focused == windowList[cycleIndex])
    end

    if not continuesCycle then
        -- Start fresh cycle - capture current window order
        windowList = windows
        cycleIndex = 1
    end

    -- Move to next window
    cycleIndex = (cycleIndex % #windowList) + 1
    windowList[cycleIndex]:focus()
end

-- Bind to Alt+Tab (change to your preference)
hs.hotkey.bind({ "alt" }, "tab", cycleApps)
