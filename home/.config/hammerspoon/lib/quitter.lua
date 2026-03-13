---@diagnostic disable-next-line: undefined-global
local hs = hs

local zombies = {
    ["Arc"] = true,
    ["Finder"] = true,
    ["Ghostty"] = true,
    ["Google Chrome Beta"] = true,
    ["Google Chrome Canary"] = true,
    ["Google Chrome Dev"] = true,
    ["Google Chrome"] = true,
    ["Keychain Access"] = true,
    ["Moonlight"] = true,
    ["Orion"] = true,
    ["Safari"] = true,
    ["Terminal"] = true,
}

hs.window.filter.default:subscribe(hs.window.filter.windowDestroyed, function(_, appName)
    local app = hs.application.get(appName)
    if not app or app:kind() == 0 or zombies[appName] then return end

    if #app:allWindows() == 0 then
        app:kill()
    end
end)
