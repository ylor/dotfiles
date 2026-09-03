local bindings = {}
local actions = {}
local menu_width = 0
local in_submap = false
local original_bind = hl.bind
local original_define_submap = hl.define_submap

local function display_keys(keys)
	keys = keys:upper():gsub("CTRL %+ ALT %+ SUPER", "HYPER")
	return keys:gsub("LEFT$", "←"):gsub("RIGHT$", "→"):gsub("UP$", "↑"):gsub("DOWN$", "↓")
end

hl.bind = function(keys, dispatcher, options)
	local description = options and options.description
	if description and not in_submap and not keys:lower():match("mouse") then
		local display = display_keys(keys)
		menu_width = math.max(menu_width, utf8.len(display))
		bindings[#bindings + 1] = {
			keys = display,
			description = description,
			action = dispatcher,
		}
	end

	return original_bind(keys, dispatcher, options)
end

hl.define_submap = function(name, reset, configure)
	return original_define_submap(name, reset, function()
		in_submap = true
		configure()
		in_submap = false
	end)
end

_G.run_keybind = function(selection)
	local action = actions[selection]
	if type(action) == "function" then
		return action()
	end

	if action then
		hl.dispatch(action)
	end
end

local function shell_quote(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function show_menu()
	table.sort(bindings, function(a, b)
		return a.keys < b.keys
	end)

	actions = {}
	local lines = {}
	for _, binding in ipairs(bindings) do
		local padding = string.rep(" ", menu_width - utf8.len(binding.keys) + 4)
		local line = binding.keys .. padding .. "→ " .. binding.description
		actions[line] = binding.action
		lines[#lines + 1] = shell_quote(line)
	end

	local input = "printf '%s\\n' " .. table.concat(lines, " ")
	local command = "selection=$(" .. input .. " | noctalia dmenu -p 'Keybindings...')"
	command = command .. "\n[ -n \"$selection\" ] && hyprctl eval \"run_keybind([[$selection]])\""
	hl.dispatch(hl.dsp.exec_cmd(command))
end

return show_menu
