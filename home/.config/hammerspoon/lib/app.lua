---@diagnostic disable-next-line: undefined-global
local hs = hs

-- Launch, focus or cycle through instances of an application
function LaunchOrFocusOrCycle(app)
    if hs.window.focusedWindow():application():name() == app then
        local appWindows = hs.application.get(app):allWindows()
        if #appWindows > 0 then
            appWindows[#appWindows]:focus()
        end
    else
        hs.application.launchOrFocus(app)
    end
end

function App(mods, key, app)
    hs.hotkey.bind(mods, key, function()
        LaunchOrFocusOrCycle(app)
    end)
end

function AppExists(app)
    return hs.application.find(app) or false
end

function AppActive(app)
    return hs.application.get(app):isFrontmost()
end

function AppRunning(app)
    return hs.application.find(app):isRunning() or false
end
