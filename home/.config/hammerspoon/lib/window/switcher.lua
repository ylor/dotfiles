---@diagnostic disable-next-line: undefined-global
local hs = hs


local list = {}
local index = 1
local last = nil

local function reset()
    list, index = {}, 1
end

local resetTimer = hs.timer.delayed.new(1, reset)

_G.windowSpaceWatcher = hs.spaces.watcher.new(function()
    reset()
    resetTimer:stop()
end):start()

_G.windowFocusWatcher = hs.window.filter.new():subscribe(
    hs.window.filter.windowFocused,
    function() resetTimer:start() end
)

local function windowHandler(reverse)
    local wf = hs.window.filter.copy(hs.window.filter.defaultCurrentSpace)
        :setScreens(hs.screen.mainScreen():getUUID())
        :setDefaultFilter({ visible = nil })
    local focused = hs.window.focusedWindow()
    local current = focused and focused:id() or nil
    if current ~= last or #list == 0 then
        list = wf:getWindows(hs.window.filter.sortByFocusedLast)
        index = 1
    end
    if #list <= 1 then return end
    if reverse then
        index = index - 1
        if index < 1 then index = #list end
    else
        index = index + 1
        if index > #list then index = 1 end
    end
    last = list[index]:id()
    list[index]:focus():flash():centerMouse()
end

local km = hs.keycodes.map
local TAB, LEFT, RIGHT, UP, DOWN = km.tab, km.left, km.right, km.up, km.down

local function handleKeyDown(event)
    local kc   = event:getKeyCode()
    local mods = event:getFlags()

    if (mods.cmd or mods.alt) and kc == TAB then
        windowHandler(mods.shift or nil)
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
            hs.window.center()
        else
            return false
        end
        return true
    end

    return false
end

_G.windowEventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handleKeyDown):start()
