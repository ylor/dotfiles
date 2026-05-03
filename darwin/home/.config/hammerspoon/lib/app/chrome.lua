---@diagnostic disable-next-line: undefined-global
local hs = hs

local apps = {
    ["Google Chrome"] = true,
    ["Google Chrome Beta"] = true,
    ["Google Chrome Dev"] = true,
}

local modal = hs.hotkey.modal.new()
-- modal:bind(Mod.main, "k", function()
--     hs.eventtap.keyStroke({ "cmd", "shift" }, "a", 0)
-- end)
modal:bind({ "cmd", "shift" }, "c", function()
    local name = hs.application.frontmostApplication():name()
    local ok, url = hs.osascript.applescript(string.format([[
        tell application "%s"
            get URL of active tab of front window
        end tell
    ]], name))
    if ok then hs.pasteboard.setContents(url) end
end)

_G.GoogleChromeWatcher = hs.application.watcher.new(function(name, eventType)
    if not apps[name] then return end

    if eventType == hs.application.watcher.activated then
        modal:enter()
    elseif eventType == hs.application.watcher.deactivated then
        modal:exit()
    end
end):start()
