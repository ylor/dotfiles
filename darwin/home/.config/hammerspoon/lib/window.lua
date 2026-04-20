---@diagnostic disable-next-line: undefined-global
local hs = hs

local function WindowCenter(win)
    win = win or hs.window.frontmostWindow()
    if not win then return end

    if not win:application():selectMenuItem({ "Window", "Center" }) then
        local s, f = win:screen():frame(), win:frame()
        f.x = s.x + (s.w - f.w) / 2
        f.y = s.y + (s.h - f.h) / 2
        win:setFrame(f)
    end
end

function WindowFill(win)
    win = win or hs.window.frontmostWindow()
    win:application():selectMenuItem({ "Window", "Fill" })
end

function WindowToggleFillCenter(win)
    win = win or hs.window.frontmostWindow()
    if not win then return end

    if win:frame() == win:screen():frame() then
        WindowCenter(win)
    else
        WindowFill(win)
    end
end

function WindowLeft(win)
    win = win or hs.window.frontmostWindow()

    local frame = win:frame()
    local screen = win:screen():frame()
    if frame.x <= screen.x then
        WindowCycleWidth(win)
    else
        win:application():selectMenuItem({ "Window", "Move & Resize", "Left" })
    end
end

function WindowRight(win)
    win = win or hs.window.frontmostWindow()
    local frame = win:frame()
    local screen = win:screen():frame()
    if frame.x + frame.w >= screen.x + screen.w then
        WindowCycleWidth(win)
    else
        win:application():selectMenuItem({ "Window", "Move & Resize", "Right" })
    end
end

function WindowFloat(win)
    win = win or hs.window.frontmostWindow()

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
    win = win or hs.window.frontmostWindow()
    if not win then return end
    if win then win:toggleFullScreen() end
end

function WindowLeftScreen(win)
    win = win or hs.window.frontmostWindow()
    local westScreen = win:screen():toWest()
    if not westScreen then return end
    win:application():selectMenuItem({ "Window", "Move to " .. westScreen:name() })
end

function WindowRightScreen(win)
    win = win or hs.window.frontmostWindow()
    local eastScreen = win:screen():toEast()
    if not eastScreen then return end
    win:application():selectMenuItem({ "Window", "Move to " .. eastScreen:name() })
end

local function centerMouse(force)
    -- win = win or hs.window.frontmostWindow()
    local win = hs.window.frontmostWindow()
    local frame = win:frame()
    if not hs.geometry.inside(hs.mouse.absolutePosition(), frame) then
        hs.mouse.absolutePosition(frame.center)
    end
end

hs.getObjectMetatable("hs.window").centerMouse = function(self)
    centerMouse(self)
    return self
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








local previousScreens = {}
hs.window.filter.new():subscribe(hs.window.filter.windowMoved, function(win)
    local winID = win:id()
    local screen = win:screen()
    local currentScreen = screen:id()
    local prevScreen = previousScreens[winID]
    previousScreens[winID] = currentScreen

    if prevScreen and prevScreen ~= currentScreen and screen:name() == "Built-in Retina Display" then
        -- hs.alert.show("Window arrived on internal screen!")
        WindowFill(win)
    end
end)
