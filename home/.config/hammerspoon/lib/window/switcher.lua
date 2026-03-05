---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Window Filter
local wf = hs.window.filter.new()
    :setCurrentSpace(true)
    :setScreens(hs.screen.primaryScreen():getUUID())

-- Window Cycling
local windowList, windowIndex = {}, 0

local function WindowHandler()
    local windows = wf:getWindows(hs.window.filter.sortByFocusedLast)
    if #windows <= 1 then return end
    if #windows ~= #windowList then
        windowList, windowIndex = windows, 2 -- start at 2 to skip current
    else
        windowIndex = (windowIndex % #windowList) + 1
    end
    local win = windowList[windowIndex]
    if win then
        win:focus()
        FlashWindow(win)
    end
end

-- Key Codes (cached)
local kc = hs.keycodes.map
local TAB, LEFT, RIGHT, UP, DOWN = kc.tab, kc.left, kc.right, kc.up, kc.down

-- Event Handler
local function handleKeyDown(event)
    local kc             = event:getKeyCode()
    local mods           = event:getFlags()
    local cmd, ctrl, alt = mods.cmd, mods.ctrl, mods.alt

    -- Cmd+Tab or Alt+Tab: cycle windows
    if (cmd or alt) and not (cmd and alt) and kc == TAB then
        WindowHandler()
        CenterMouse()
        return true
    end

    -- Ctrl+Arrow: window management
    if ctrl then
        if kc == LEFT then
            WindowLeft(); return true
        end
        if kc == RIGHT then
            WindowRight(); return true
        end
        if kc == UP then
            WindowFill(); return true
        end
        if kc == DOWN then
            WindowCenter(); return true
        end
    end

    -- Hyper+Down: float
    if cmd and ctrl and alt and kc == DOWN then
        WindowFloat(); return true
    end

    return false
end

EventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handleKeyDown):start()
SpaceWatcher = hs.spaces.watcher.new(function()
    windowList, windowIndex = {}, 1
end):start()
