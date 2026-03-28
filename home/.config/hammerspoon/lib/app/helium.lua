---@diagnostic disable-next-line: undefined-global
local hs = hs

local modal = hs.hotkey.modal.new()
modal:bind(Mod.main, "k", function()
    hs.eventtap.keyStroke({ "cmd", "shift" }, "a")
end)

_G.heliumWatcher = hs.application.watcher.new(function(app, eventType)
    if app ~= "Helium" then return end

    if eventType == hs.application.watcher.activated then
        modal:enter()
    elseif eventType == hs.application.watcher.deactivated then
        modal:exit()
    end
end):start()
