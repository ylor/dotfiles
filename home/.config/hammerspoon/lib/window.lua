---@diagnostic disable-next-line: undefined-global
local hs = hs

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
    end

    return false
end)
WindowManager:start()
