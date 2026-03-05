---@diagnostic disable-next-line: undefined-global
local hs = hs

function FlashWindow(win)
    local f = win:frame()
    if not f then return end

    local canvas = hs.canvas.new(f)

    -- Outer glow (soft, wide, low opacity)
    canvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = { red = 0.6, green = 0.8, blue = 1.0, alpha = 0.15 },
        strokeWidth = 4,
        roundedRectRadii = { xRadius = 12, yRadius = 12 },
        frame = { x = 0, y = 0, w = f.w, h = f.h },
    })

    -- Mid rim (frosted blue-white)
    canvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = { red = 0.75, green = 0.88, blue = 1.0, alpha = 0.45 },
        strokeWidth = 2,
        roundedRectRadii = { xRadius = 12, yRadius = 12 },
        frame = { x = 1, y = 1, w = f.w - 2, h = f.h - 2 },
    })

    -- Inner specular highlight (top edge shimmer)
    canvas:appendElements({
        type = "rectangle",
        action = "stroke",
        strokeColor = { white = 1.0, alpha = 0.6 },
        strokeWidth = 0.75,
        roundedRectRadii = { xRadius = 11, yRadius = 11 },
        frame = { x = 2, y = 2, w = f.w - 4, h = f.h - 4 },
    })

    canvas:show()

    -- Fade out by deleting after short delay
    -- (hs.canvas doesn't support alpha animation natively, so we step it)
    local hz = win:screen():currentMode().freq or 60
    local steps, duration = hz, 0.666
    local interval = duration / steps
    local step = 0
    hs.timer.doWhile(
        function() return step < steps end,
        function()
            step = step + 1
            local alpha = (1.0 - (step / steps)) ^ 1.5 -- gentle ease-in to the fade
            canvas:alpha(alpha)
            if step >= steps then canvas:delete() end
        end,
        interval
    )
end
