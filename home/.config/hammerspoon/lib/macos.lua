---@diagnostic disable-next-line: undefined-global
local hs = hs

function SelectMenuItem(table)
    hs.application.frontmostApplication():selectMenuItem(table)
end

function ShowDesktop()
    hs.spaces.toggleShowDesktop()
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

function WindowFullscreen()
    local win = hs.window.focusedWindow()
    if win then
        win:toggleFullScreen()
    end
end

function RunCommand(bin)
    local home = os.getenv("HOME")
    local cmd = home .. "/.local/bin/" .. bin
    hs.execute(hs.fs.symlinkAttributes(cmd).target)
end
