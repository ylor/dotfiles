---@diagnostic disable-next-line: undefined-global
local hs = hs
require("lib.apps")

-- Chrome
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

-- Finder
function FinderJumpToFolder()
    hs.eventtap.keyStroke({ "cmd", "shift" }, "g", 0)
end

local scrollReverse = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)

    if button == 3 then
        hs.eventtap.keyStroke({ "cmd" }, "[", 0)
        return true
    elseif button == 4 then
        hs.eventtap.keyStroke({ "cmd" }, "]", 0)
        return true
    end
    return false
end)

_G.FinderModal = AppModal("Finder",
    function() scrollReverse:start() end,
    function() scrollReverse:stop() end)

-- Helium
function HeliumSelectAll()
    hs.eventtap.keyStroke({ "cmd", "shift" }, "a", 0)
end

_G.HeliumModal = AppModal("Helium")
