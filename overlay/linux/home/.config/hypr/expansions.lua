local config_dir = debug.getinfo(1, "S").source:match("^@(.*/)")
local expander_plugin = config_dir .. "plugins/hypr-expander/hypr-expander-0.0.1.so"
local expander_file = io.open(expander_plugin, "r")

if not expander_file then
	return
end

expander_file:close()
hl.permission(expander_plugin, "plugin", "allow")
hl.plugin.load(expander_plugin)

local expander = hl.plugin.hypr_expander
if not expander then
	return
end

local function decode_base64(encoded)
	assert(encoded:match("^[%w+/=]+$"), "invalid base64 value")

	local command = "printf '%s' '" .. encoded .. "' | base64 --decode"
	local process = assert(io.popen(command, "r"))
	local decoded = process:read("*a")
	process:close()
	assert(decoded ~= "", "base64 decode failed")
	return decoded
end

expander.add({
	trigger = "@@",
	replacement = decode_base64("cm9seXJleWVzQG1lLmNvbQ=="),
})
