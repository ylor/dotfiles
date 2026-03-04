---@diagnostic disable-next-line: undefined-global
local hs = hs

local exempt = {
    ["Finder"] = true,
    ["Keychain Access"] = true,
    ["Safari"] = true,
    ["Google Chrome"] = true,
    ["Google Chrome Beta"] = true,
    ["Google Chrome Dev"] = true,
    ["Google Chrome Canary"] = true,
    ["Terminal"] = true,
    ["Arc"] = true,
    ["Orion"] = true,
    ["Ghostty"] = true,
    ["Moonlight"] = true,
}

hs.window.filter.default:subscribe(hs.window.filter.windowDestroyed, function(_, appName)
    local app = hs.application.get(appName)
    if app and app:kind() > 0 and not exempt[appName] and #app:allWindows() == 0 then
        app:kill()
    end
end)
