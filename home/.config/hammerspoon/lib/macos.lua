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
