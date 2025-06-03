---@diagnostic disable-next-line: undefined-global
local hs = hs

function CenterMouse(window)
    local pos = hs.geometry(hs.mouse.absolutePosition())
    local frame = window:frame()
    if not pos:inside(frame) then
        local current_screen = hs.mouse.getCurrentScreen()
        local window_screen = window:screen()
        if current_screen and window_screen and current_screen ~= window_screen then
            -- avoid getting the mouse stuck on a screen corner by moving through the center of each screen
            hs.mouse.absolutePosition(current_screen:frame().center)
            hs.mouse.absolutePosition(window_screen:frame().center)
        end
        hs.mouse.absolutePosition(frame.center)
    end
end

WindowFilter = hs.window.filter.new({
    override = {
        visible = true,
    }
}):setDefaultFilter({
    visible = true,
})
WindowFilter:subscribe(hs.window.filter.windowFocused, function(window)
    CenterMouse(window)
end)
