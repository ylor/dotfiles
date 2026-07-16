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
    local bucket = byLastChar[lastChar]
    if not bucket then
        bucket = {}
        byLastChar[lastChar] = bucket
    end
    bucket[#bucket + 1] = { trigger = trigger, replacement = replacement }
end

_G.textExpander = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.leftMouseDown,
    hs.eventtap.event.types.rightMouseDown,
}, function(event)
    if event:getType() ~= hs.eventtap.event.types.keyDown then
        buffer = ""
        return false
    end

    local flags = event:getFlags()
    if event:getKeyCode() == hs.keycodes.map.escape
        or event:getKeyCode() == hs.keycodes.map.left
        or event:getKeyCode() == hs.keycodes.map.right
        or event:getKeyCode() == hs.keycodes.map.up
        or event:getKeyCode() == hs.keycodes.map.down
        or flags.cmd or flags.ctrl or flags.alt then
        buffer = ""
        return false
    end

    local chars = event:getCharacters()
    if not chars or chars == "" then return false end

    buffer = (buffer .. chars):sub(-(maxLen + 1))

    local bucket = byLastChar[chars:sub(-1)]
    if not bucket then return false end

    for _, entry in ipairs(bucket) do
        local trigger, replacement = entry.trigger, entry.replacement
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
