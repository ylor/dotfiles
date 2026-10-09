---@diagnostic disable-next-line: undefined-global
local hs = hs
require("lib.spaces")

local menu = hs.menubar.new()
local function updateMenu()
    local index, total = SpaceInfo()
    -- the primary screen can briefly vanish during sleep/wake or display changes
    if not index then
        return
    end
    local dots = string.rep("○", index - 1) .. "◉" .. string.rep("○", total - index)
    menu:setTitle(dots)
end

updateMenu()

_G.SpaceMenubarSpaceWatcher = hs.spaces.watcher.new(updateMenu):start()
_G.SpaceMenubarScreenWatcher = hs.screen.watcher.new(updateMenu):start()

menu:setClickCallback(hs.openConsole)
