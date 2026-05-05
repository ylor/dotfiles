---@diagnostic disable-next-line: undefined-global
local hs = hs

local menu = hs.menubar.new()
local function updateMenu()
    local index, total = SpaceInfo()
    local dots = string.rep("○", index - 1) .. "◉" .. string.rep("○", total - index)
    menu:setTitle(dots)
end

updateMenu()

_G.SpaceMenubarSpaceWatcher = hs.spaces.watcher.new(updateMenu):start()
_G.SpaceMenubarScreenWatcher = hs.screen.watcher.new(updateMenu):start()

menu:setClickCallback(hs.openConsole)
