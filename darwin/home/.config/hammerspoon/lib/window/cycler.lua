---@diagnostic disable-next-line: undefined-global
local hs = hs

local widthCycles = { 0.4, 0.5, 0.6 }


local function cycleIndex(winW, screenW)
    for i, w in ipairs(widthCycles) do
        if math.abs(winW / screenW - w) < 0.05 then return i end
    end
end

local function anchor(frame, screen)
    if frame.w >= screen.w - 10 then return "center" end
    local threshold = screen.w * 0.1
    if frame.x - screen.x < threshold then return "left" end
    if (screen.x + screen.w) - (frame.x + frame.w) < threshold then return "right" end
    return "center"
end

function WindowCycleWidth(win)
    win = win or hs.window.focusedWindow()
    if not win then return end

    local screen   = win:screen():frame()
    local frame    = win:frame()
    local newWidth = math.floor(screen.w * widthCycles[(cycleIndex(frame.w, screen.w) or 0) % #widthCycles + 1])
    local side     = anchor(frame, screen)

    local newX
    if side == "left" then
        newX = screen.x
    elseif side == "right" then
        newX = screen.x + screen.w - newWidth
    else
        newX = math.floor(frame.x + frame.w / 2 - newWidth / 2)
    end

    newX = math.max(screen.x, math.min(newX, screen.x + screen.w - newWidth))
    win:setFrame({ x = newX, y = screen.y, w = newWidth, h = screen.h })
end

hs.hotkey.bind({ "ctrl" }, "W", WindowCycleWidth)
