---@diagnostic disable-next-line: undefined-global
local hs = hs

local windowList = {}
local windowIndex = 0
local function WindowHandler()
    local filter = hs.window.filter.new():setCurrentSpace(true):setScreens(hs.screen.mainScreen():getUUID())
    local windows = filter:getWindows(hs.window.filter.sortByFocusedLast)
    if #windows <= 1 then return end

    local focused = hs.window.focusedWindow()
    local newCycle = windowList == {} or #windows ~= #windowList
    local newFocus = focused ~= windowList[windowIndex]

    if newCycle or newFocus then
        windowList = windows
        windowIndex = 1
    end

    windowIndex = (windowIndex % #windowList) + 1
    windowList[windowIndex]:focus()
end

local function handleKeyDown(event)
    local kc = event:getKeyCode()
    local key = hs.keycodes.map
    local mods = event:getFlags()

    local cmd = mods:containExactly({ "cmd" }) or mods:containExactly({ "cmd", "fn" })
    local ctrl = mods:containExactly({ "ctrl" }) or mods:containExactly({ "ctrl", "fn" })
    local alt = mods:containExactly({ "alt" }) or mods:containExactly({ "alt", "fn" })
    local hyper = mods:containExactly({ "ctrl", "alt", "cmd" }) or mods:containExactly({ "ctrl", "alt", "cmd", "fn" })

    if cmd and kc == key["tab"] then
        WindowHandler()
        return true
    end

    if cmd and kc == key["`"] then
        WindowHandler()
        return true
    end

    if ctrl and kc == key["left"] then
        WindowLeft()
    elseif ctrl and kc == key["down"] then
        WindowCenter()
    elseif ctrl and kc == key["up"] then
        WindowFill()
    elseif ctrl and kc == key["right"] then
        WindowRight()
    elseif hyper and kc == key["down"] then
        WindowFloat()
    else
        return false
    end

    return true
end

EventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handleKeyDown)
EventTapper:start()
