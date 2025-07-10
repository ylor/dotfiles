---@diagnostic disable-next-line: undefined-global
local hs = hs

local space = hs.spaces.activeSpaceOnScreen("Primary")
if space == 1 then
    hs.alert.show(space)
else
    hs.alert.show(space - 1)
end
