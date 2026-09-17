local hs = hs ---@diagnostic disable-line: undefined-global

local email = Work and "cnJleWVzQHBhcGEuY29t" or "cm9seXJleWVzQG1lLmNvbQo=ˆ"

local triggers = {
	["@@"] = hs.base64.decode(email),
	["@dd"] = function()
		return os.date("%Y-%m-%d")
	end,
	["@ts"] = function()
		return os.date("!%Y-%m-%dT%H:%M:%SZ")
	end,
	["aapl"] = "",
	["shrugg"] = "¯\\_(ツ)_/¯",
	["tmm"] = "™",
	["xx"] = "×",
	["->"] = "→",
	["<-"] = "←",
}

local SPACE = " "

local buffer = ""
local maxLen = 0
for trigger in pairs(triggers) do
	maxLen = math.max(maxLen, #trigger)
end

-- keys that always abort a pending trigger, checked with one getKeyCode()
-- call and one table lookup instead of a chain of equality comparisons
local RESET_KEYCODES = {
	[hs.keycodes.map.escape] = true,
	[hs.keycodes.map.left] = true,
	[hs.keycodes.map.right] = true,
	[hs.keycodes.map.up] = true,
	[hs.keycodes.map.down] = true,
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
	if not chars or chars == "" then
		return false
	end

	-- room for the longest trigger, the space that fires it, and the
	-- character before the trigger
	buffer = (buffer .. chars):sub(-(maxLen + 2))

	if chars ~= SPACE then
		return false
	end

	for trigger, replacement in pairs(triggers) do
		local typed = buffer:sub(-(#trigger + 1), -2)
		local charBefore = buffer:sub(-(#trigger + 2), -(#trigger + 2))
		if typed == trigger and not charBefore:match("%w") then
			buffer = ""
			textExpander:stop()
			for _ = 1, #trigger do
				hs.eventtap.keyStroke({}, "delete", 0)
			end
			hs.timer.doAfter(0.02, function()
				if type(replacement) == "function" then
					replacement = replacement()
				end
				-- the space was swallowed to fire the trigger, so put it back
				hs.eventtap.keyStrokes(replacement .. SPACE)
				textExpander:start()
			end)
			return true
		end
	end

	return false
end)

textExpander:start()
