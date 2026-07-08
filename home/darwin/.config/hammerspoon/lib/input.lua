local hs = hs ---@diagnostic disable-line: undefined-global

function ShowClipboard()
    hs.eventtap.keyStroke({ "cmd" }, "space", 0)
    hs.timer.doAfter(0.02, function()
        hs.eventtap.keyStroke({ "cmd" }, "4", 0)
    end
    )
end
