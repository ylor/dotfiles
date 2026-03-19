---@diagnostic disable-next-line: undefined-global
local hs = hs

require("lib.app.finder")

function AppHandler(app)
    local focusedWin = hs.window.focusedWindow()

    -- Gather windows for the app that are strictly on the main screen
    local windows = hs.fnutils.filter(
        hs.window.filter.new(app):getWindows(),
        function(win) return win:screen() == hs.screen.mainScreen() end
    )

    -- Action 1: If no windows exist, launch or focus the app
    if #windows == 0 then
        return hs.application.launchOrFocus(app)
    end

    -- Action 2: If the app isn't focused, focus its first window
    if not focusedWin or focusedWin:application():name() ~= app then
        return windows[1]:focus():flash():centerMouse()
    end

    -- Action 3: If the app is already focused and has multiple windows, cycle them
    if #windows > 1 then
        table.sort(windows, function(a, b) return a:id() < b:id() end)

        -- hs.fnutils.indexOf replaces the manual for-loop
        local currentIndex = hs.fnutils.indexOf(windows, focusedWin) or 1
        return windows[(currentIndex % #windows) + 1]:focus():flash():centerMouse()
    end
end
