---@diagnostic disable-next-line: undefined-global
local hs = hs

function SelectMenuItem(table)
    hs.application.frontmostApplication():selectMenuItem(table)
end

function WindowCenter()
    SelectMenuItem({ "Window", "Center" })
end

function WindowFill()
    SelectMenuItem({ "Window", "Fill" })
end

function WindowLeft()
    SelectMenuItem({ "Window", "Move & Resize", "Left" })
end

function WindowRight()
    SelectMenuItem({ "Window", "Move & Resize", "Right" })
end

function WindowFloat()
    local win = hs.window.focusedWindow()
    local frame = win:screen():frame()

    frame.w = frame.w / 1.75
    frame.h = frame.h / 1.25

    win:setFrame(frame):centerOnScreen()
end

function RunCommand(bin)
    local home = os.getenv("HOME")
    local cmd = home .. "/.local/bin/" .. bin
    hs.alert.show(cmd)
    hs.execute(hs.fs.symlinkAttributes(cmd).target)
end

function Focus(direction)
    if direction == "left" then
        hs.window.focusedWindow():focusWindowWest()
    elseif direction == "down" then
        hs.window.focusedWindow():focusWindowSouth()
    elseif direction == "up" then
        hs.window.focusedWindow():focusWindowNorth()
    elseif direction == "right" then
        hs.window.focusedWindow():focusWindowEast()
    end

    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local center = hs.geometry.rectMidPoint(frame)
    hs.mouse.absolutePosition(center)
end
