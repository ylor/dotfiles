---@diagnostic disable-next-line: undefined-global
local hs = hs

local function WindowCenter(win)
    win = win or hs.window.focusedWindow()
    if not win then return end

    if not win:application():selectMenuItem({ "Window", "Center" }) then
        local s, f = win:screen():frame(), win:frame()
        f.x = s.x + (s.w - f.w) / 2
        f.y = s.y + (s.h - f.h) / 2
        win:setFrame(f)
    end
end

function WindowFill(win)
    if not win then win = hs.application.frontmostApplication() end
    win:selectMenuItem({ "Window", "Fill" })
end

function WindowLeft(win)
    if not win then win = hs.application.frontmostApplication() end
    win:selectMenuItem({ "Window", "Move & Resize", "Left" })
end

function WindowRight(win)
    if not win then win = hs.application.frontmostApplication() end
    win:selectMenuItem({ "Window", "Move & Resize", "Right" })
end

function WindowFloat(win)
    if not win then win = hs.window.focusedWindow() end

    local frame = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    local height = max.h * 0.8
    local width = height * (4 / 3)

    frame.w = width
    frame.h = height
    frame.x = max.x + (max.w / 2) - (width / 2)
    frame.y = max.y + (max.h / 2) - (height / 2)

    win:setFrame(frame)
end

function WindowFullscreen(win)
    if not win then win = hs.window.focusedWindow() end
    if not win then return end
    if win then win:toggleFullScreen() end
end

function WindowLeftScreen()
    local app = hs.application.frontmostApplication()
    local win = hs.window.focusedWindow()
    local westScreen = win:screen():toWest()
    if not westScreen then return end
    app:selectMenuItem({ "Window", "Move to " .. westScreen:name() })
end

function WindowRightScreen()
    local app = hs.application.frontmostApplication()
    local win = hs.window.focusedWindow()
    local eastScreen = win:screen():toEast()
    if not eastScreen then return end
    app:selectMenuItem({ "Window", "Move to " .. eastScreen:name() })
end

hs.getObjectMetatable("hs.window").centerMouse = function(self)
    hs.mouse.absolutePosition(self:frame().center)
end

hs.window.center = function(self)
    WindowCenter(self)
    return self
end

hs.window.toggleFullscreen = function(self)
    WindowFullscreen(self)
    return self
end

hs.window.float = function(self)
    WindowFloat(self)
    return self
end

require("lib.window.flash")
require("lib.window.menu")
require("lib.window.switcher")
