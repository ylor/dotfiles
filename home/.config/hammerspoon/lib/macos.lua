---@diagnostic disable-next-line: undefined-global
local hs = hs

function SelectMenuItem(table)
    hs.application.frontmostApplication():selectMenuItem(table)
end

function WindowLeft()
    SelectMenuItem({ "Window", "Move & Resize", "Left" })
end

function WindowFill()
    SelectMenuItem({ "Window", "Fill" })
end

function WindowCenter()
    SelectMenuItem({ "Window", "Center" })
end

function WindowRight()
    SelectMenuItem({ "Window", "Move & Resize", "Right" })
end

function ExtractText()
    hs.execute("./")
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

    -- local win = hs.window.focusedWindow()
    -- local frame = win:frame()
    -- local center = hs.geometry.rectMidPoint(frame)
    -- hs.mouse.absolutePosition(center)
end
