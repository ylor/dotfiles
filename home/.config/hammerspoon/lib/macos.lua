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
    local bin = hs.fs.pathToAbsolute(hs.configdir .. "/bin")
    local ocr = bin .. "/trex"
    local real = hs.fs.symlinkAttributes(ocr)
    hs.execute(real.target)
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

-- MARK: AutoQuit
WindowFilter = hs.window.filter.new()
WindowFilter:subscribe(hs.window.filter.windowDestroyed, function(window, application)
    local app = hs.application.get(application)
    if app:kind() == 0 or #app:allWindows() > 0 then return end
    app:kill()
end)
