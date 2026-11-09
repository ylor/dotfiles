local hs = hs ---@diagnostic disable-line: undefined-global

local index, last, list

local function reset()
    index, last, list = 1, nil, {}
end
reset()

local timer = hs.timer.delayed.new(1, reset)

local function switcher(reverse)
    local focused = hs.window.focusedWindow()
    local current = focused and focused:id()
    if current ~= last or #list == 0 then
        local screen = focused and focused:screen() or hs.screen.mainScreen()
        local all = hs.window.filter.defaultCurrentSpace:getWindows(hs.window.filter.sortByFocusedLast)
        -- check live screen; window.filter caches it and can be stale after moves
        list = hs.fnutils.filter(all, function(w) return w:screen():id() == screen:id() end)
        index = 1
    end
    if #list <= 1 then return end
    index = reverse and ((index - 2) % #list) + 1 or (index % #list) + 1
    last = list[index]:id()
    list[index]:focus():centerMouse()
end

hs.window.filter.default:subscribe(
    hs.window.filter.windowFocused,
    function() timer:start() end
)

local TAB = hs.keycodes.map.tab
_G.TabberEventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown },
    function(event)
        local mods = event:getFlags()
        if (mods.cmd or mods.alt) and event:getKeyCode() == TAB then
            switcher(mods.shift)
            return true
        end
    end):start()
