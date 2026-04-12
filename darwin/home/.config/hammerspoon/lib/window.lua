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

function WindowFlash(win)
    local f = win:frame()
    if not f then return end
    if not win:isVisible() or hs.window.focusedWindow() ~= win then return end

    local canvas = hs.canvas.new(f)
    local r = 16

    canvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = { black = 1.0, alpha = 0.2 },
        strokeWidth = 1,
        roundedRectRadii = { xRadius = r, yRadius = r },
        frame = { x = 0.5, y = 0.5, w = f.w - 1, h = f.h - 1 }
    }, {
        type = "rectangle",
        action = "stroke",
        strokeColor = { white = 1.0, alpha = 0.6 },
        strokeWidth = 2,
        roundedRectRadii = { xRadius = r - 1, yRadius = r - 1 },
        frame = { x = 1.5, y = 1.5, w = f.w - 3, h = f.h - 3 }
    })

    canvas:show()

    local duration = 0.5
    local hz = win:screen():currentMode().freq or 60
    local step = 0
    local steps = math.floor(hz * duration)

    if hs.battery.powerSource() == "Battery Power" then
        hz = 60
    end

    hs.timer.doWhile(
        function()
            if hs.window.focusedWindow() ~= win then
                canvas:delete()
                return false
            end
            return step < steps
        end,
        function()
            step = step + 1
            local progress = step / steps
            local alpha = math.cos(progress * (math.pi / 2))
            canvas:alpha(alpha)

            if step >= steps then canvas:delete() end
        end,
        1 / hz
    )
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

local function centerMouse(win)
    win = win or hs.window.focusedWindow()
    if not win then return end
    local frame = win:frame()
    if not hs.geometry.inside(hs.mouse.absolutePosition(), frame) then
        hs.mouse.absolutePosition(frame.center)
    end
end

hs.getObjectMetatable("hs.window").centerMouse = function(self)
    centerMouse(self)
    return self
end

hs.getObjectMetatable("hs.window").flash = function(self)
    WindowFlash(self)
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
