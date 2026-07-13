local hs = hs ---@diagnostic disable-line: undefined-global

local email = Work and "cnJleWVzQHBhcGEuY29t" or "cm9seXJleWVzQG1lLmNvbQo=ˆ"

local triggers = {
    ["@@"]     = hs.base64.decode(email),
    ["@dd"]    = function() return os.date("%Y-%m-%d") end,
    ["@ts"]    = function() return os.date("!%Y-%m-%dT%H:%M:%SZ") end,
    ["aapl"]   = "",
    ["shrugg"] = "¯\\_(ツ)_/¯",
    ["tmm"]    = "™",
    ["xx"]     = "×",
}

local buffer = ""
local maxLen = 0
for k in pairs(triggers) do maxLen = math.max(maxLen, #k) end

_G.textExpander = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.leftMouseDown,
    hs.eventtap.event.types.rightMouseDown,
}, function(event)
    local flags = event:getFlags()
    if event:getType() ~= hs.eventtap.event.types.keyDown
        or event:getKeyCode() == hs.keycodes.map.escape
        or event:getKeyCode() == hs.keycodes.map.left
        or event:getKeyCode() == hs.keycodes.map.right
        or event:getKeyCode() == hs.keycodes.map.up
        or event:getKeyCode() == hs.keycodes.map.down
        or flags.cmd or flags.ctrl or flags.alt then
        buffer = ""
        return false
    end

    local chars = event:getCharacters()
    if not chars then return false end

    buffer = (buffer .. chars):sub(-(maxLen + 1))

    for trigger, replacement in pairs(triggers) do
        if buffer:sub(- #trigger) == trigger
            and not buffer:sub(-(#trigger + 1), -(#trigger + 1)):match("%w") then
            buffer = ""
            textExpander:stop()
            for _ = 1, #trigger - 1 do
                hs.eventtap.keyStroke({}, "delete", 0)
            end
            hs.timer.doAfter(0.02, function()
                if type(replacement) == "function" then replacement = replacement() end
                hs.eventtap.keyStrokes(replacement)
                textExpander:start()
            end)
            return true
        end
    end

    return false
end)

textExpander:start()
