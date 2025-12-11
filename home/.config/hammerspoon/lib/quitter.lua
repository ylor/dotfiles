---@diagnostic disable-next-line: undefined-global
local hs = hs

local exempt = {
    ["Finder"] = true,
    ["Keychain Access"] = true,
    ["Safari"] = true,
    ["Google Chrome"] = true,
    ["Terminal"] = true,
    ["Arc"] = true,
    ["Orion"] = true,
    ["Ghostty"] = true,
}

WindowFilter = hs.window.filter.default
WindowFilter:subscribe(hs.window.filter.windowDestroyed, function(window, application)
    local app = hs.application.get(application)
    if not app then return end
    if app:kind() == 0 then return end
    if exempt[app:name()] then return end
    if #app:allWindows() > 0 then return end
    app:kill()
end)
