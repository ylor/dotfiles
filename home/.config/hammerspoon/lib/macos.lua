---@diagnostic disable-next-line: undefined-global
local hs = hs

function ShowDesktop()
    hs.spaces.toggleShowDesktop()
end

function WindowCenter()
    hs.application.frontmostApplication():selectMenuItem({ "Window", "Center" })
end

function WindowFill()
    hs.application.frontmostApplication():selectMenuItem({ "Window", "Fill" })
end

function WindowLeft()
    hs.application.frontmostApplication():selectMenuItem({ "Window", "Move & Resize", "Left" })
end

function WindowRight()
    hs.application.frontmostApplication():selectMenuItem({ "Window", "Move & Resize", "Right" })
end

function WindowFloat()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    -- Define the size of the square (e.g., 80% of the screen's height)
    local sideLength = max.h * 0.8

    -- Apply dimensions
    f.w = sideLength
    f.h = sideLength

    -- Calculate centering coordinates
    f.x = max.x + (max.w / 2) - (sideLength / 2)
    f.y = max.y + (max.h / 2) - (sideLength / 2)

    win:setFrame(f)
end

function WindowFullscreen()
    local win = hs.window.focusedWindow()
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

function RunCommand(bin)
    local home = os.getenv("HOME")
    local cmd = home .. "/.local/bin/" .. bin
    hs.execute(hs.fs.symlinkAttributes(cmd).target)
end
