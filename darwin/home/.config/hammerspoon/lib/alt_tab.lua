---@diagnostic disable-next-line: undefined-global
local hs    = hs

local index = 1
local last
local list  = {}

local function reset()
    index, last, list = 1, nil, {}
end

local km = hs.keycodes.map
local TAB, LEFT, RIGHT, UP, DOWN = km.tab, km.left, km.right, km.up, km.down

local function windowHandler(reverse)
    local wf = hs.window.filter.copy(hs.window.filter.defaultCurrentSpace)
        :setScreens(hs.screen.mainScreen():getUUID())
    local focused = hs.window.focusedWindow()
    local current = focused and focused:id()
    if current ~= last or #list == 0 then
        list = wf:getWindows(hs.window.filter.sortByFocusedLast)
        index = 1
    end
    if #list <= 1 then return end
    index = reverse and ((index - 2) % #list) + 1 or (index % #list) + 1
    last = list[index]:id()
    list[index]:focus():centerMouse()
end

local function handleKeyDown(event)
    local kc   = event:getKeyCode()
    local mods = event:getFlags()

    if (mods.cmd or mods.alt) and kc == TAB then
        windowHandler(mods.shift)
        return true
    end

    if mods.ctrl and not (mods.alt or mods.cmd or mods.shift) then
        if kc == LEFT then
            WindowLeft()
        elseif kc == RIGHT then
            WindowRight()
        elseif kc == UP then
            WindowFill()
        elseif kc == DOWN then
            WindowCenter()
        else
            return false
        end
        return true
    end

    return false
end

local timer = hs.timer.delayed.new(1, reset)

_G.SwitcherFocusWatcher = hs.window.filter.new():subscribe(
    hs.window.filter.windowFocused,
    function() timer:start() end
)

_G.SwitcherSpaceWatcher = hs.spaces.watcher.new(function()
    reset()
    timer:stop()
end):start()

_G.SwitcherEventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handleKeyDown):start()
