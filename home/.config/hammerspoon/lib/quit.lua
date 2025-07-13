---@diagnostic disable-next-line: undefined-global
local hs = hs

local exempt = {
    Finder = true,
    Hammerspoon = true,
}

local function hsQuit(app)
    if not app then return end
    if app:kind() == 0 then return end
    if exempt[app:name()] then return end

    if #app:allWindows() == 0 then
        app:kill()
    end
end

hs.window.filter.new():subscribe(hs.window.filter.windowDestroyed, function(win, appName)
    local app = hs.application.get(appName)
    hs.timer.doAfter(1, hsQuit(app))
end)
