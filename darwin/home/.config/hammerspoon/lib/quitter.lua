---@diagnostic disable-next-line: undefined-global
local hs = hs

local pinned = {}
local output = hs.execute("defaults read com.apple.dock persistent-apps")
for bundleID in output:gmatch('"bundle%-identifier" = "([^"]+)";') do
    pinned[bundleID] = true
end

local exempt = {
    ["Finder"] = true,
    ["Keychain Access"] = true,
    -- ["Moonlight"] = true
}

hs.window.filter.default:subscribe(hs.window.filter.windowDestroyed, function(_, appName)
    local app = hs.application.get(appName)
    if app:kind() == 0 or exempt[appName] then return end
    if pinned[app:bundleID()] then return end

    local wf = hs.window.filter.new(appName)
    if #wf:getWindows() == 0 then
        app:kill()
    end
end)
