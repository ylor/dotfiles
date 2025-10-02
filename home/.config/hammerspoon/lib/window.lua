---@diagnostic disable-next-line: undefined-global
local hs = hs

local function handleKeyDown(event)
    local flags = event:getFlags()
    local kc = event:getKeyCode()

    local ctrl = flags:containExactly({ "ctrl" }) or flags:containExactly({ "ctrl", "fn" })
    local hyper = flags:containExactly({ "ctrl", "alt", "cmd" }) or flags:containExactly({ "ctrl", "alt", "cmd", "fn" })

    if ctrl and kc == hs.keycodes.map["left"] then
        WindowLeft()
    elseif ctrl and kc == hs.keycodes.map["down"] then
        WindowCenter()
    elseif ctrl and kc == hs.keycodes.map["up"] then
        WindowFill()
    elseif ctrl and kc == hs.keycodes.map["right"] then
        WindowRight()
    elseif hyper and kc == hs.keycodes.map["down"] then
        WindowFloat()
    else
        return false
    end

    return true
end

-- Global function to prevent garbage collection
WindowManager = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, handleKeyDown)
WindowManager:start()
