---@diagnostic disable-next-line: undefined-global
local hs = hs

local email = Work and "cnJleWVzQHBhcGEuY29t" or "cm9seXJleWVzQ@1lLmNvbQ=="
local snippets = {
    ["@@"]     = hs.base64.decode(email),
    ["shrugg"] = "¯\\_(ツ)_/¯",
    ["tmm"]    = "™",
    ["xx"]     = "×",
    ["foo"]    = "bar",
    ["@date"]  = function() return os.date("%Y-%m-%d") end,
    ["@ts"]    = function() return os.date("!%Y-%m-%dT%H:%M:%SZ") end,
}

local buffer = ""

_G.snippetKeyWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local flags = event:getFlags()
    local keyCode = event:getKeyCode()
    local char = event:getCharacters()
    local k = hs.keycodes.map

    -- ignore modifier combos
    if flags.cmd or flags.ctrl or flags.alt then
        buffer = ""
        return false
    end

    -- Handle Backspace
    if keyCode == k["delete"] then
        if #buffer > 0 then
            local offset = utf8.offset(buffer, -1)
            if offset then buffer = string.sub(buffer, 1, offset - 1) end
        end
        return false
    end

    -- 3. EXPAND ON WORD BOUNDARIES: Define what triggers an expansion
    local isBoundary = false
    local boundaryChar = ""

    if keyCode == k["space"] then
        isBoundary = true; boundaryChar = " "
    elseif keyCode == k["return"] then
        isBoundary = true; boundaryChar = "\n"
    elseif char and string.match(char, "[%.,;!%?]") then
        isBoundary = true; boundaryChar = char
    end

    if isBoundary then
        local expansion = snippets[buffer]

        if expansion then
            local bksps = utf8.len(buffer)
            buffer = ""
            for i = 1, bksps do hs.eventtap.keyStroke({}, "delete", 0) end
            local out = type(expansion) == "function" and expansion() or expansion
            hs.eventtap.keyStrokes(out .. boundaryChar)

            return true
        else
            buffer = ""
            return false
        end
    end

    -- Reset on arrow keys/navigation
    if keyCode == k["up"] or keyCode == k["down"] or keyCode == k["left"] or keyCode == k["right"] or keyCode == k["escape"] then
        buffer = ""
        return false
    end

    -- Append character to buffer (filter non-printables)
    if char and #char > 0 and not char:match("%c") then
        buffer = buffer .. char
    end

    return false
end)

-- Mouse Watcher
_G.snippetMouseWatcher = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function()
    buffer = ""
    return false
end)

_G.snippetKeyWatcher:start()
_G.snippetMouseWatcher:start()
