---@diagnostic disable-next-line: undefined-global
local hs = hs

local exempt = {
    Hammerspoon = true,
    Finder = true
}

local function hsQuit(app)
    if not app or exempt[app:name()] then return end

    local visibleWindows = hs.fnutils.filter(app:allWindows(), function(win)
        return win:isVisible()
    end)

    if #visibleWindows == 0 then
        app:kill()
    end
end

hs.window.filter.new():subscribe(hs.window.filter.windowDestroyed, function(win, appName)
    local app = hs.application.get(appName)
    hs.timer.doAfter(1, hsQuit(app))
end)
