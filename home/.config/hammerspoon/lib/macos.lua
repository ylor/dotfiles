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

function RunCommand(bin)
    local dir = hs.fs.pathToAbsolute(hs.configdir .. "/bin")
    local cmd = dir .. "/" .. bin
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

function Unlock1Password()
    hs.execute("/opt/homebrew/bin/op account get")
end

hs.hotkey.bind("alt", ".", Unlock1Password)

-- MARK: AutoQuit
local exempt = {
    ["Finder"] = true,
    ["Safari"] = true,
    ["Terminal"] = true,
    ["Arc"] = true,
    ["Ghostty"] = true,
}

-- Set up the window filter
WindowFilter = hs.window.filter.new()
WindowFilter:subscribe(hs.window.filter.windowDestroyed, function(window, application)
    local app = hs.application.get(application)
    if not app then return end
    if app:kind() == 0 then return end
    if exempt[app:name()] then return end
    if #app:allWindows() > 0 then return end
    app:kill()
end)
