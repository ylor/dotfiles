local hs = hs ---@diagnostic disable-line: undefined-global


local index, last, list = 1, nil, {}

local function reset()
    index, last, list = 1, nil, {}
end

local timer = hs.timer.delayed.new(1, reset)

local wf = hs.window.filter.copy(hs.window.filter.defaultCurrentSpace)
    :setScreens(hs.screen.mainScreen():getUUID())

local function switcher(reverse)
    local current = hs.window.focusedWindow()
    current = current and current:id()
    if current ~= last or #list == 0 then
        list = wf:getWindows(hs.window.filter.sortByFocusedLast)
        index = 1
    end
    if #list <= 1 then return end
    index = reverse and ((index - 2) % #list) + 1 or (index % #list) + 1
    last = list[index]:id()
    list[index]:focus():centerMouse()
end

_G.SwitcherFocusWatcher = hs.window.filter.new():subscribe(
    hs.window.filter.windowFocused,
    function() timer:start() end
)

_G.SwitcherSpaceWatcher = hs.spaces.watcher.new(function()
    reset()
    -- timer:stop()
end):start()

local TAB = hs.keycodes.map.tab
_G.TabberEventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown },
    function(event)
        local mods = event:getFlags()
        if (mods.cmd or mods.alt) and event:getKeyCode() == TAB then
            switcher(mods.shift)
            return true
        end
    end):start()
