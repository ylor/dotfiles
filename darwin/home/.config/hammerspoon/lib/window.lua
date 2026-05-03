---@diagnostic disable-next-line: undefined-global
local hs = hs


-- helpers

local function centerMouse(win)
    win = win or hs.window.frontmostWindow()
    local frame = win:frame()
    if not hs.geometry.inside(hs.mouse.absolutePosition(), frame) then
        hs.mouse.absolutePosition(frame.center)
    end
end

local function cycleWindowWidth(win)
    win          = win or hs.window.focusedWindow()

    local screen = win:screen():frame()
    local frame  = win:frame()
    local cycles = { 0.5, 0.6 }

    local idx    = 0
    for i, w in ipairs(cycles) do
        if math.abs(frame.w / screen.w - w) < 0.05 then idx = i end
    end

    local newW     = math.floor(screen.w * cycles[idx % #cycles + 1])
    local isLeft   = frame.x - screen.x < screen.w * 0.1
    local isRight  = (screen.x + screen.w) - (frame.x + frame.w) < screen.w * 0.1
    local centered = frame.w >= screen.w - 10 or (not isLeft and not isRight)

    local newX
    if centered then
        newX = math.floor(frame.x + frame.w / 2 - newW / 2)
    elseif isLeft then
        newX = screen.x
    else
        newX = screen.x + screen.w - newW
    end

    newX = math.max(screen.x, math.min(newX, screen.x + screen.w - newW))
    win:setFrame({ x = newX, y = screen.y, w = newW, h = screen.h })
end

local function WindowFloat(win, scale)
    win = win or hs.window.frontmostWindow()
    local max = win:screen():frame()
    local h = max.h * scale
    local w = h * 1.5

    win:setFrame({
        x = max.x + (max.w - w) / 2,
        y = max.y + (max.h - h) / 2,
        w = w,
        h = h,
    })
    hs.timer.doAfter(hs.window.animationDuration, function()
        win:application():selectMenuItem({ "Window", "Center" })
    end)
end


-- window management

function WindowCenter(win)
    win = win or hs.window.frontmostWindow()
    if not win:application():selectMenuItem({ "Window", "Center" }) then
        WindowMini(win)
    end
end

function WindowLeft(win)
    win          = win or hs.window.frontmostWindow()
    local screen = win:screen():frame()
    if not
        win:application():selectMenuItem({ "Window", "Move & Resize", "Left" }) then
        win:setFrame({
            x = screen.x,
            y = screen.y,
            w = screen.w / 2,
            h = screen.h
        })
    end
end

function WindowRight(win)
    win          = win or hs.window.frontmostWindow()
    local screen = win:screen():frame()
    if not win:application():selectMenuItem({ "Window", "Move & Resize", "Right" }) then
        win:setFrame({
            x = screen.x + screen.w / 2,
            y = screen.y,
            w = screen.w / 2,
            h = screen.h
        })
    end
end

function WindowFill(win)
    win = win or hs.window.frontmostWindow()
    if not win:application():selectMenuItem({ "Window", "Fill" }) then
        win:moveToUnit({ 0, 0, 1, 1 })
    end
end

function WindowFillToggle(win)
    win = win or hs.window.frontmostWindow()
    if win:frame() == win:screen():frame() then
        if not win:application():selectMenuItem({ "Window", "Move & Resize", "Return to Previous Size" }) then
            WindowFloat(win)
        end
    else
        WindowFill(win)
    end
end

function WindowMaxi(win) WindowFloat(win, 0.9) end

function WindowMini(win) WindowFloat(win, 0.5) end

function MoveWindowLeftScreen(win)
    win = win or hs.window.frontmostWindow()
    local westScreen = win:screen():toWest()
    if not westScreen then return end
    win:application():selectMenuItem({ "Window", "Move to " .. westScreen:name() })
end

function MoveWindowRightScreen(win)
    win = win or hs.window.frontmostWindow()
    local eastScreen = win:screen():toEast()
    if not eastScreen then return end
    win:application():selectMenuItem({ "Window", "Move to " .. eastScreen:name() })
end

-- extensions

hs.getObjectMetatable("hs.window").centerMouse = function(self)
    centerMouse(self)
    return self
end

-- hotkeys

hs.hotkey.bind({ "ctrl" }, "W", cycleWindowWidth)

-- events
local actions = {
    [hs.keycodes.map.left]  = WindowLeft,
    [hs.keycodes.map.right] = WindowRight,
    [hs.keycodes.map.up]    = WindowFill,
    [hs.keycodes.map.down]  = WindowCenter,
}

_G.WindowEventTapper = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local mods = event:getFlags()
    local ctrl = mods:containExactly({ "ctrl" }) or mods:containExactly({ "ctrl", "fn" })
    if not ctrl then return end

    local action = actions[event:getKeyCode()]
    if action then
        action()
        return true
    end
end):start()


local previousScreens = {}
hs.window.filter.new():subscribe(hs.window.filter.windowMoved, function(win)
    local winID = win:id()
    local screen = win:screen()
    local currentScreen = screen:id()
    local prevScreen = previousScreens[winID]
    previousScreens[winID] = currentScreen

    if prevScreen and prevScreen ~= currentScreen and screen:name() == "Built-in Retina Display" then
        WindowFill(win)
    end
end)
