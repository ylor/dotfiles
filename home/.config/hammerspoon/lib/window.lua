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

function WindowFlash(win)
    local f = win:frame()
    if not f then return end
    if not win:isVisible() or hs.window.focusedWindow() ~= win then return end

    local canvas = hs.canvas.new(f)
    local r = 16

    canvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { white = 1.0, alpha = 0.02 },
        roundedRectRadii = { xRadius = r, yRadius = r },
        frame = { x = 0, y = 0, w = f.w, h = f.h }
    }, {
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

local function centerMouse(win, force)
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
