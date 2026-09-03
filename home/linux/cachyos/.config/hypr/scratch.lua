local M = {}
local scratch_classes = {}

local function contains(cursor, x, y, width, height)
	local inside_x = cursor.x >= x and cursor.x < x + width
	local inside_y = cursor.y >= y and cursor.y < y + height
	return inside_x and inside_y
end

local function is_noctalia_ui_layer(layer)
	local namespace = layer.namespace
	return namespace ~= "noctalia-wallpaper" and namespace:match("^noctalia%-")
end

local function keeps_scratch_open(window)
	if not window then
		return false
	end

	local class = window.class and window.class:lower()
	if class == "dev.noctalia.noctalia" then
		return true
	end

	local title = window.title and window.title:lower()
	return window.floating and class == "1password" and title == "1password"
end

local function scratch_name(workspace)
	if not workspace then
		return nil
	end

	local name = workspace.name:match("^special:(.+)$")
	if scratch_classes[name] then
		return name
	end
end

local function active_name()
	return scratch_name(hl.get_active_special_workspace())
end

function M.dismiss_active()
	local name = active_name()
	if not name then
		return false
	end

	hl.dispatch(hl.dsp.workspace.toggle_special(name))
	return true
end

function M.dismiss_on_outside_click()
	local name = active_name()
	if not name then
		return
	end

	local cursor = hl.get_cursor_pos()
	local workspace_name = "special:" .. name

	for _, layer in ipairs(hl.get_layers()) do
		local inside = contains(cursor, layer.x, layer.y, layer.w, layer.h)
		if is_noctalia_ui_layer(layer) and inside then
			return
		end
	end

	for _, window in ipairs(hl.get_windows()) do
		local workspace = window.workspace
		local inside = contains(cursor, window.at.x, window.at.y, window.size.x, window.size.y)
		if workspace and workspace.name == workspace_name and inside then
			return
		end
	end

	M.dismiss_active()
end

function M.focus_workspace(workspace)
	return function()
		M.dismiss_active()
		hl.dispatch(hl.dsp.focus({ workspace = workspace }))
	end
end

function M.action(name, terminal, program)
	local class = "com.mitchellh.ghostty." .. name
	scratch_classes[name] = class

	local command = terminal .. " --gtk-single-instance=false --class=" .. class
	if program then
		command = command .. " -e " .. program
	end

	return function()
		local window = hl.get_window("class:^(" .. class .. ")$")
		if window then
			hl.dispatch(hl.dsp.workspace.toggle_special(name))
			return
		end

		local rules = {
			workspace = "special:" .. name,
			float = true,
			center = true,
			size = {
				"monitor_w * 0.6",
				"monitor_w * 0.6 * 2 / 3",
			},
		}
		hl.dispatch(hl.dsp.exec_cmd(command, rules))
	end
end

hl.on("workspace.active", function()
	M.dismiss_active()
end)

hl.on("window.active", function(window)
	local special_workspace = hl.get_active_special_workspace()
	if not special_workspace then
		return
	end

	if keeps_scratch_open(window) then
		return
	end

	local window_workspace = window and window.workspace
	if window_workspace and window_workspace.name == special_workspace.name then
		return
	end

	M.dismiss_active()
end)

hl.on("window.open", function(window)
	if keeps_scratch_open(window) then
		return
	end

	local name = scratch_name(window and window.workspace)
	if not name or window.class == scratch_classes[name] then
		return
	end

	hl.dispatch(hl.dsp.window.move({
		workspace = hl.get_active_workspace(),
		window = "address:" .. window.address,
		follow = false,
	}))
	M.dismiss_active()
end)

return M
