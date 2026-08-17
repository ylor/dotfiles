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

-- bucket triggers by their last character so a keystroke only needs to
-- check the handful of triggers it could possibly complete, not all of them
local byLastChar = {}
for trigger, replacement in pairs(triggers) do
    maxLen = math.max(maxLen, #trigger)
    local lastChar = trigger:sub(-1)
    byLastChar[lastChar] = byLastChar[lastChar] or {}
    byLastChar[lastChar][trigger] = replacement
end

-- keys that always abort a pending trigger, checked with one getKeyCode()
-- call and one table lookup instead of a chain of equality comparisons
local RESET_KEYCODES = {
    [hs.keycodes.map.escape] = true,
    [hs.keycodes.map.left]   = true,
    [hs.keycodes.map.right]  = true,
    [hs.keycodes.map.up]     = true,
    [hs.keycodes.map.down]   = true,
}

local function resetBuffer()
    buffer = ""
    return false
end

_G.textExpander = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.leftMouseDown,
    hs.eventtap.event.types.rightMouseDown,
}, function(event)
    if event:getType() ~= hs.eventtap.event.types.keyDown then
        return resetBuffer()
    end

    if RESET_KEYCODES[event:getKeyCode()] then
        return resetBuffer()
    end

    local flags = event:getFlags()
    if flags.cmd or flags.ctrl or flags.alt then
        return resetBuffer()
    end

    local chars = event:getCharacters()
    if not chars or chars == "" then return false end

    buffer = (buffer .. chars):sub(-(maxLen + 1))

    local bucket = byLastChar[chars:sub(-1)]
    if not bucket then return false end

    for trigger, replacement in pairs(bucket) do
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
