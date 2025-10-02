---@diagnostic disable-next-line: undefined-global
local hs = hs

local function handleAppLaunch(app, appName)
    local screen = hs.screen:primaryScreen():getUUID()
    local spaces = hs.spaces.allSpaces()[screen]
    while #spaces < 3 do
        hs.spaces.addSpaceToScreen(screen)
        spaces = hs.spaces.allSpaces()[screen]
    end

    local apps = {
        ["Safari"] = 1,
        ["Ghostty"] = 1,
        ["Messages"] = 3,
    }

    print(appName)

    if apps[appName] then
        local space = spaces[apps[appName]]
        local window = app:mainWindow()
        hs.spaces.moveWindowToSpace(window, space)
        window:focus()
    end
end

---needs to be a global var otherwise it gets garbage collected apparently
---@diagnostic disable-next-line: lowercase-global
appwatcher = hs.application.watcher
    .new(function(appName, event, app)
        if event == hs.application.watcher.launched then
            handleAppLaunch(app, appName)
            hs.alert.show(app)
        end
    end)
    :start()
