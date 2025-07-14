---@diagnostic disable-next-line: undefined-global
local hs = hs

function WindowFloat()
    local win = hs.window.focusedWindow()
    local frame = win:screen():frame()

    -- size
    local w = frame.w / 1.5
    local h = frame.h / 1.25

    -- position
    local x = frame.x + (frame.w - w) / 2
    local y = frame.y + (frame.h - h) / 2

    win:setFrame(hs.geometry.rect(x, y, w, h), 0)
end

WindowManager = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local app = hs.application.frontmostApplication()
    local flags = event:getFlags()
    local ctrl = flags:containExactly({ "ctrl" }) or flags:containExactly({ "ctrl", "fn" })
    local kc = event:getKeyCode()

    if ctrl and kc == hs.keycodes.map["left"] then
        app:selectMenuItem({ "Window", "Move & Resize", "Left" })
        return true
    elseif ctrl and kc == hs.keycodes.map["down"] then
        app:selectMenuItem({ "Window", "Center" })
        return true
    elseif ctrl and kc == hs.keycodes.map["up"] then
        app:selectMenuItem({ "Window", "Fill" })
        return true
    elseif ctrl and kc == hs.keycodes.map["right"] then
        app:selectMenuItem({ "Window", "Move & Resize", "Right" })
        return true
    else
        return false
    end
end)
WindowManager:start()
