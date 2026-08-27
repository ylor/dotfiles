local M = {}
local classes = {}

local function active_name()
	local workspace = hl.get_active_special_workspace()
	if not workspace then
		return nil
	end

	local name = workspace.name:match("^special:(.+)$")
	if not classes[name] then
		return nil
	end

	return name
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

	for _, window in ipairs(hl.get_windows()) do
		local workspace = window.workspace
		local at = window.at
		local size = window.size
		local inside_x = cursor.x >= at.x and cursor.x < at.x + size.x
		local inside_y = cursor.y >= at.y and cursor.y < at.y + size.y

		if workspace and workspace.name == workspace_name and inside_x and inside_y then
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
	classes[name] = class
	classes[class] = true

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

	local window_class = window and window.class
	if window_class and window_class:lower() == "1password" then
		return
	end

	local window_workspace = window and window.workspace
	if window_workspace and window_workspace.name == special_workspace.name then
		return
	end

	M.dismiss_active()
end)

hl.on("window.open", function(window)
	local workspace = window and window.workspace
	if not workspace or not classes[workspace.name:match("^special:(.+)$")] then
		return
	end

	if classes[window.class] then
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
