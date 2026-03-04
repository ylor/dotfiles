---@diagnostic disable-next-line: undefined-global
local hs = hs

local wf = hs.window.filter.new():setCurrentSpace(true):setScreens(hs.screen.primaryScreen():getUUID())
local windowList = {}
local windowIndex = 0

local function WindowHandler()
    local windows = wf:getWindows(hs.window.filter.sortByFocusedLast)
    if #windows <= 1 then return end

    -- Simplified logic: if the count changed, we reset the cycle
    if #windows ~= #windowList then
        windowList = windows
        windowIndex = 1
    else
        windowIndex = (windowIndex % #windowList) + 1
    end

    if windowList[windowIndex] then
        windowList[windowIndex]:focus()
    end
end

-- 3. Key Map for Performance (Avoids repeated string lookups in hs.keycodes)
local keys = hs.keycodes.map

local function handleKeyDown(event)
    local kc      = event:getKeyCode()
    local mods    = event:getFlags()
    local isCmd   = mods.cmd and not (mods.ctrl or mods.alt)
    local isCtrl  = mods.ctrl and not (mods.cmd or mods.alt)
    local isAlt   = mods.alt and not (mods.cmd or mods.ctrl)
    local isHyper = mods.cmd and mods.ctrl and mods.alt

    -- window cycling
    if isCmd or isAlt then
        if (kc == keys["tab"]) then
            WindowHandler(); return true
        end
    end

    -- window "management"
    if isCtrl then
        if kc == keys["left"] then
            WindowLeft(); return true
        end
        if kc == keys["down"] then
            WindowCenter(); return true
        end
        if kc == keys["up"] then
            WindowFill(); return true
        end
        if kc == keys["right"] then
            WindowRight(); return true
        end
    end

    if isHyper and kc == keys["down"] then
        WindowFloat(); return true
    end

    return false
end

EventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handleKeyDown):start()
