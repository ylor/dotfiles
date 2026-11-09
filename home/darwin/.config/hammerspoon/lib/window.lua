---@diagnostic disable-next-line: undefined-global
local hs = hs

function WindowCycleWidth(win)
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

-- The app's Window menu item, or a screen unit rect when it has none
local function menuOrUnit(path, unit)
    return function(win)
        win = win or hs.window.frontmostWindow()
        if not win:application():selectMenuItem(path) then
            win:moveToUnit(unit)
        end
    end
end

WindowLeft = menuOrUnit({ "Window", "Move & Resize", "Left" }, { 0, 0, 0.5, 1 })
WindowRight = menuOrUnit({ "Window", "Move & Resize", "Right" }, { 0.5, 0, 0.5, 1 })
WindowFill = menuOrUnit({ "Window", "Fill" }, { 0, 0, 1, 1 })

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

-- `direction` is an hs.screen neighbor method: "toWest" or "toEast"
local function moveWindowToScreen(direction)
    return function(win)
        win = win or hs.window.frontmostWindow()
        local screen = win:screen()
        local target = screen[direction](screen)
        if not target then return end
        win:application():selectMenuItem({ "Window", "Move to " .. target:name() })
    end
end

MoveWindowLeftScreen = moveWindowToScreen("toWest")
MoveWindowRightScreen = moveWindowToScreen("toEast")

function AppZen()
    local screen = hs.screen.mainScreen()
    local focused = hs.window.focusedWindow()
    local visible = hs.fnutils.filter(hs.window.visibleWindows(), function(w) return w:screen() == screen end)

    if #visible > 1 and focused then
        local focusedApp = focused:application()
        local hidden = {}
        for _, win in ipairs(visible) do
            if win ~= focused then
                local app = win:application()
                if app == focusedApp then
                    win:minimize()
                elseif not hidden[app] then
                    app:hide()
                    hidden[app] = true
                end
            end
        end
    else
        for _, app in ipairs(hs.application.runningApplications()) do
            if app:isHidden() then app:unhide() end
        end
        for _, win in ipairs(hs.window.minimizedWindows()) do
            win:unminimize()
        end
        focused:focus()
    end
end

-- extensions

hs.getObjectMetatable("hs.window").centerMouse = function(self)
    local frame = self:frame()
    if not hs.geometry.inside(hs.mouse.absolutePosition(), frame) then
        hs.mouse.absolutePosition(frame.center)
    end
    return self
end

-- events

function WindowArrowKeyHandler(actions)
    return function(event)
        local mods = event:getFlags()
        local ctrl = mods:containExactly({ "ctrl" }) or mods:containExactly({ "ctrl", "fn" })
        if not ctrl then return end

        local action = actions[event:getKeyCode()]
        if action then
            action()
            return true
        end
    end
end
