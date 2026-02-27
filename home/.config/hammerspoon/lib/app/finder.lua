---@diagnostic disable-next-line: undefined-global
local hs = hs

hs.hotkey.bind({ "cmd" }, "L", function()
    local app = hs.application.frontmostApplication()

    if app:title() == "Finder" then
        app:selectMenuItem({ "Go", "Go to Folder…" })
    else
        -- Optional: allow Cmd+L to work normally in other apps
        hs.eventtap.keyStroke({ "cmd" }, "L")
    end
end)
