---@diagnostic disable-next-line: undefined-global
local hs = hs

hs.getObjectMetatable("hs.window").centerMouse = function(self)
    hs.mouse.absolutePosition(self:frame().center)
end

hs.window.toggleFullscreen = function()
    local win = hs.window.focusedWindow()
    if win then win:toggleFullScreen() end
end

hs.window.float = function()
    WindowFloat()
end

require("lib.window.flash")
require("lib.window.menu")
require("lib.window.switcher")
