---@diagnostic disable-next-line: undefined-global
local hs = hs
require("lib.spaces")

local menu = hs.menubar.new()

local total = 0 -- space count from the last lookup

local function render(index)
    menu:setTitle(string.rep("○", index - 1) .. "◉" .. string.rep("○", total - index))
end

local function updateMenu()
    local active, count = SpaceInfo()
    -- the primary screen can briefly vanish during sleep/wake or display changes
    if not active then
        return
    end
    total = count
    render(active)
end

updateMenu()

_G.SpaceMenubarSpaceWatcher = hs.spaces.watcher.new(updateMenu):start()
_G.SpaceMenubarScreenWatcher = hs.screen.watcher.new(updateMenu):start()

-- Mission Control reports a ctrl+1-5 switch ~300ms after the keypress, so show
-- it on the keypress. A tap, not hs.hotkey, so the key still reaches Mission Control.
_G.SpaceMenubarKeyTapper = hs.eventtap
    .new({ hs.eventtap.event.types.keyDown }, function(event)
        local index = tonumber(hs.keycodes.map[event:getKeyCode()])
        if not (index and index >= 1 and index <= math.min(5, total) and event:getFlags():containExactly({ "ctrl" })) then
            return false
        end
        -- The window drag's ctrl+N switches the window's screen, which may not be the menubar's.
        if event:getProperty(hs.eventtap.event.properties.eventSourceUnixProcessID) == hs.processInfo.processID then
            return false
        end
        render(index)
        return false
    end)
    :start()

menu:setClickCallback(hs.openConsole)
