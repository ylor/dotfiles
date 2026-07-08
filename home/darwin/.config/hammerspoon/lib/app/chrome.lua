---@diagnostic disable-next-line: undefined-global
local hs = hs

function CopyChromeTabURL()
    local name = hs.application.frontmostApplication():name()
    local ok, url = hs.osascript.applescript(string.format([[
        tell application "%s"
            get URL of active tab of front window
        end tell
    ]], name))
    if ok then hs.pasteboard.setContents(url) end
end

_G.ChromeModal = AppModal({ "Google Chrome", "Google Chrome Beta", "Google Chrome Dev" })
-- ChromeModal:bind(Mod.main, "k", function()
--     hs.eventtap.keyStroke({ "cmd", "shift" }, "a", 0)
-- end)
