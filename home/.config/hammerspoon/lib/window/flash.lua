---@diagnostic disable-next-line: undefined-global
local hs = hs

function FlashWindow(win)
    local f = win:frame()
    if not f then return end
    if not win:isVisible() or hs.window.focusedWindow() ~= win then return end

    local canvas = hs.canvas.new(f)
    local r = 16

    canvas:appendElements({
        type = "rectangle",
        action = "fill",
        fillColor = { white = 1.0, alpha = 0.02 },
        roundedRectRadii = { xRadius = r, yRadius = r },
        frame = { x = 0, y = 0, w = f.w, h = f.h }
    })

    canvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = { black = 1.0, alpha = 0.2 },
        strokeWidth = 1,
        roundedRectRadii = { xRadius = r, yRadius = r },
        frame = { x = 0.5, y = 0.5, w = f.w - 1, h = f.h - 1 }
    })

    canvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = { white = 1.0, alpha = 0.6 },
        strokeWidth = 2,
        roundedRectRadii = { xRadius = r - 1, yRadius = r - 1 },
        frame = { x = 1.5, y = 1.5, w = f.w - 3, h = f.h - 3 }
    })

    canvas:show()

    local hz = win:screen():currentMode().freq or 60
    local duration = 0.5
    local steps = math.floor(hz * duration)
    local step = 0

    hs.timer.doWhile(
        function()
            if hs.window.focusedWindow() ~= win then
                canvas:delete()
                return false
            end
            return step < steps
        end,
        function()
            step = step + 1
            local progress = step / steps
            local alpha = math.cos(progress * (math.pi / 2))
            canvas:alpha(alpha)

            if step >= steps then canvas:delete() end
        end,
        1 / hz -- Fire exactly at the monitor's refresh rate
    )
end

hs.getObjectMetatable("hs.window").flash = function(self)
    FlashWindow(self)
    return self
end
