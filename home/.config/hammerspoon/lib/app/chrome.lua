---@diagnostic disable-next-line: undefined-global
local hs = hs

local modal = hs.hotkey.modal.new()
modal:bind(Mod.main, "k", function()
    hs.eventtap.keyStroke({ "cmd", "shift" }, "a")
end)

local apps = {
    ["Google Chrome"] = true,
    ["Google Chrome Beta"] = true,
    ["Google Chrome Dev"] = true,
    ["Helium"] = true,
}

_G.chromeWatcher = hs.application.watcher.new(function(name, eventType)
    if not apps[name] then return end

    if eventType == hs.application.watcher.activated then
        modal:enter()
    elseif eventType == hs.application.watcher.deactivated then
        modal:exit()
    end
end):start()
