---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Window Cycling
local wf = hs.window.filter.defaultCurrentSpace:setScreens(hs.screen.mainScreen():getUUID())
local windowList, windowIndex = {}, 0

local function WindowHandler(reverse)
    local windows = wf:getWindows(hs.window.filter.sortByFocusedLast)
    if #windows <= 1 then return end
    if #windows ~= #windowList then
        windowList = windows
        windowIndex = reverse and #windowList or 2
    else
        if reverse then
            windowIndex = (windowIndex - 2) % #windowList + 1
        else
            windowIndex = (windowIndex % #windowList) + 1
        end
    end

    local win = windowList[windowIndex]
    if win then
        win:focus()
        win:flash()
        win:centerMouse()
    end
end

-- Key Codes (cached)
local km = hs.keycodes.map
local TAB, LEFT, RIGHT, UP, DOWN = km.tab, km.left, km.right, km.up, km.down

-- Event Handler
local function handleKeyDown(event)
    local kc                    = event:getKeyCode()
    local mods                  = event:getFlags()
    local cmd, ctrl, alt, shift = mods.cmd, mods.ctrl, mods.alt, mods.shift

    -- cycle windows
    if (cmd or alt) and kc == TAB then
        if shift then
            WindowHandler(true)
        else
            WindowHandler()
        end
        return true
    end

    -- Ctrl+Arrow: window "management"
    if ctrl and not (alt or cmd or shift) then
        if kc == LEFT then
            WindowLeft(); return true
        elseif kc == RIGHT then
            WindowRight(); return true
        elseif kc == UP then
            WindowFill(); return true
        elseif kc == DOWN then
            WindowCenter(); return true
        end
    end

    -- Hyper+Arrow: float
    if cmd and ctrl and alt and not shift and kc == DOWN then
        WindowFloat(); return true
    end

    return false
end

EventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handleKeyDown):start()
SpaceWatcher = hs.spaces.watcher.new(function()
    windowList, windowIndex = {}, 1
end):start()
