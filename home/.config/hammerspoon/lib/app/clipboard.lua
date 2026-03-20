---@diagnostic disable-next-line: undefined-global
local hs = hs

hs.spotlight.showClipboard = function()
    hs.eventtap.keyStroke({ "cmd" }, "space", 0)
    hs.timer.doAfter(0.05, function()
        hs.eventtap.keyStroke({ "cmd" }, "4", 0)
    end)
end
