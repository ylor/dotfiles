-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

local hyper = "CTRL + ALT + SUPER"

o.bind(hyper .. " + A", "Switch audio output", "omarchy-audio-output-switch", { locked = true })
o.bind(hyper .. " + L", "Lock system", "omarchy-system-lock")
o.bind(hyper .. " + V", "Volume mixer", { panel = "omarchy.audio" })
o.bind(hyper .. " + UP", "Brightness up", "omarchy-brightness-display +5%", { locked = true, repeating = true })
o.bind(hyper .. " + DOWN", "Brightness down", "omarchy-brightness-display 5%-", { locked = true, repeating = true })
-- Step to the next multiple of 20 (p = current %), skipping when it falls outside 0-100.
-- The lock drops a tick while the previous DDC read+write (~300ms) is still running.
-- DDC floors 0% to 1%, so 1 counts as 0.
local function brightness_step(next_percent)
  return [[exec 9>"$XDG_RUNTIME_DIR/brightness-step.lock"; flock -n 9 || exit
    p=$(omarchy-brightness-display) || exit
    [ "$p" -le 1 ] && p=0
    t=$(( ]] .. next_percent .. [[ ))
    [ "$t" -ge 0 ] && [ "$t" -le 100 ] && omarchy-brightness-display "$t%"]]
end

-- Keyboard repeat (40Hz) outruns DDC, so holding steps on a slower timer instead.
local brightness_hold
local function stop_brightness_hold()
  if brightness_hold then brightness_hold:set_enabled(false) end
end
local function brightness_hold_bind(key, description, next_percent)
  local cmd = brightness_step(next_percent)
  o.bind(hyper .. " + " .. key, description, function()
    stop_brightness_hold()
    hl.exec_cmd(cmd)
    brightness_hold = hl.timer(function() hl.exec_cmd(cmd) end, { timeout = 400, type = "repeat" })
  end, { locked = true })
  -- Any-mod release, so letting go of hyper first still stops it.
  hl.bind(key, stop_brightness_hold, { release = true, ignore_mods = true, non_consuming = true, locked = true })
end
brightness_hold_bind("RIGHT", "Brightness step up 10%", "(p / 10 + 1) * 10")
brightness_hold_bind("LEFT", "Brightness step down 10%", "((p + 9) / 10 - 1) * 10")
o.bind(hyper .. " + BACKSPACE", "Brightness 0%", "omarchy-brightness-display 0%", { locked = true })
-- The LG ignores standard input switching (VCP 0x60), so use its private 0xF4: 0x90 = HDMI-1, 0xD0 = DP-1.
-- It also can't report the current input, so remember the last choice here.
local on_hdmi = false
o.bind(hyper .. " + I", "Toggle monitor input DP-1/HDMI-1", function()
  on_hdmi = not on_hdmi
  local code = on_hdmi and "0x90" or "0xD0"
  hl.exec_cmd("ddcutil --sn 409NTHM0S137 --noverify --i2c-source-addr=0x50 setvcp 0xF4 " .. code)
end, { locked = true })
o.bind("ALT + mouse_up", "Brightness up", "omarchy-brightness-display +5%", { locked = true })
o.bind("ALT + mouse_down", "Brightness down", "omarchy-brightness-display 5%-", { locked = true })

hl.unbind("SUPER + W")
o.bind("SUPER + I", "Browser", { omarchy = "browser" })
-- Stepping back from scrolling lands on tiling, so floating is never reached.
local tiling_scrolling_toggle = [[if [ "$(omarchy-hyprland-workspace-layout-current)" = scrolling ]; then omarchy-hyprland-workspace-layout-toggle back; else omarchy-hyprland-workspace-layout-toggle; fi]]
o.rebind("SUPER + L", "Toggle tiling/scrolling layout", tiling_scrolling_toggle)
o.rebind("SUPER + Home", "Rebalance window split", hl.dsp.layout("splitratio 1.0 exact"))

local function cycle_window(forward)
  hl.dispatch(hl.dsp.window.cycle_next({ next = forward }))
  local active = hl.get_active_window()
  if not active then return end

  local workspace = active.workspace
  -- Raising fullscreen alone leaves floating windows allowed above it.
  if workspace and active.fullscreen ~= 0 then
    for _, window in ipairs(workspace:get_windows()) do
      local other_floating = window.floating and window.address ~= active.address
      if other_floating and not window.pinned then
        hl.dispatch(hl.dsp.window.alter_zorder({ mode = "bottom", window = window }))
      end
    end
  end

  hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top", window = active }))
end

for _, modifier in ipairs({ "ALT", "SUPER" }) do
  o.rebind(modifier .. " + TAB", "Next window in active workspace", function() cycle_window(true) end)
  o.rebind(modifier .. " + SHIFT + TAB", "Previous window in active workspace", function() cycle_window(false) end)
end

o.rebind(hyper .. " + TAB", "Toggle last two workspaces", hl.dsp.focus({ workspace = "previous" }))

-- Step volume onto the next multiple of 5, so a level set by hand (e.g. 37%)
-- snaps back to the 5% grid. Shell, because reading the volume in Lua blocks Hyprland.
local volume_up = [[v=$(LC_ALL=C pactl get-sink-volume "$(omarchy-audio-output-sink)" | grep -oP '[0-9]+(?=%)' | head -n1); omarchy-audio-output-volume +$((5 - v % 5))]]
local volume_down = [[v=$(LC_ALL=C pactl get-sink-volume "$(omarchy-audio-output-sink)" | grep -oP '[0-9]+(?=%)' | head -n1); omarchy-audio-output-volume -$(((v + 4) % 5 + 1))]]

o.rebind("XF86AudioRaiseVolume", "Volume up", volume_up, { locked = true, repeating = true })
o.rebind("XF86AudioLowerVolume", "Volume down", volume_down, { locked = true, repeating = true })

-- The bar is the monitor's reserved top strip, minus 10% at each end.
local function over_bar()
  local cursor = hl.get_cursor_pos()
  local monitor = hl.get_monitor_at_cursor()
  if not cursor or not monitor then return false end

  local width = monitor.width / monitor.scale
  local x = cursor.x - monitor.x
  local within_x = x >= width * 0.1 and x < width * 0.9
  local within_y = cursor.y - monitor.y < monitor.reserved.top
  return within_x and within_y
end

o.bind("mouse_up", "Volume up over Omarchy bar", function() if over_bar() then hl.exec_cmd(volume_up) end end, { locked = true, non_consuming = true })
o.bind("mouse_down", "Volume down over Omarchy bar", function() if over_bar() then hl.exec_cmd(volume_down) end end, { locked = true, non_consuming = true })

-- scroll_event_delay is low for volume, so workspace scrolling waits 300ms
-- itself; otherwise one wheel flick skips several workspaces.
local workspace_scroll_cooling = false

local function scroll_workspace(direction)
  if workspace_scroll_cooling then return end
  workspace_scroll_cooling = true
  hl.timer(function() workspace_scroll_cooling = false end, { timeout = 300, type = "oneshot" })
  hl.dispatch(hl.dsp.focus({ workspace = direction }))
end

o.rebind("SUPER + mouse_down", "Scroll active workspace forward", function() scroll_workspace("m+1") end)
o.rebind("SUPER + mouse_up", "Scroll active workspace backward", function() scroll_workspace("m-1") end)

hl.bind("SUPER + M", function()
  if hl.get_workspace("special:minimized") then
    hl.dispatch(hl.dsp.window.move({
      workspace = hl.get_active_workspace(),
      window = "tag:minimized",
    }))
    hl.dispatch(hl.dsp.window.clear_tags({ window = "tag:minimized" }))
  else
    hl.dispatch(hl.dsp.window.tag({ tag = "minimized", window = hl.get_active_window() }))
    hl.dispatch(hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
  end
end)

-- flea --default: begin. Written by `flea --default`; `flea --default off` removes the block whole.
hl.unbind("SUPER + SHIFT + F")
o.rebind("SUPER + E", "File manager", { launch = 'flea --gui' })
hl.unbind("SUPER + ALT + SHIFT + F")
o.rebind("SUPER + SHIFT + E", "File manager (cwd)", { launch = 'flea --gui "$(omarchy-cmd-terminal-cwd)"' })
-- flea --default: end.

-- flea --picker: begin. Written by `flea --picker`; `flea --picker off` removes the block whole.
o.window("com.thisisgm.flea.picker", { tag = "+floating-window" })
-- flea --picker: end.

o.bind("ALT + SPACE", "oma-cast launcher", hl.dsp.global("oma-cast:toggle"))
hl.layer_rule({ match = { namespace = "^oma-cast$" }, no_anim = true, animation = "none" })
o.bind(hyper .. " + SPACE", "Omarchy menu", { menu = "root" })
if o.cmd_present("oma-cast") then
  o.rebind("SUPER + SPACE", "oma-cast launcher", hl.dsp.global("oma-cast:toggle"))
end

-- In scrolling layout, toggle full-width column instead of tiled fullscreen.
-- Neighbouring columns peek in at the edges so they stay findable.
local peek = 0.03

local function monitor_width()
  local monitor = hl.get_active_monitor()
  return monitor.width / monitor.scale
end

-- Stacked windows share their column's x, so they count as neither side.
local function neighbours(window)
  local left, right = 0, 0
  for _, other in ipairs(hl.get_active_workspace():get_windows()) do
    if not other.floating then
      if other.at.x < window.at.x then left = 1 end
      if other.at.x > window.at.x then right = 1 end
    end
  end
  return left, right
end

-- The view only scrolls to fit the column, so shift it to leave room for each peek.
local function center_between_peeks()
  local window = hl.get_active_window()
  local left, right = neighbours(window)
  local width = monitor_width()
  local target_x = hl.get_active_monitor().x + (width - window.size.x + (left - right) * peek * width) / 2
  hl.dispatch(hl.dsp.layout(string.format("move %+d", math.floor(target_x - window.at.x + 0.5))))
end

local function is_wide(window)
  return window.size.x > 0.9 * monitor_width()
end

o.rebind("SUPER + CTRL + F", "Tiled full screen / column full width", function()
  local window = hl.get_active_window()
  local scrolling = hl.get_active_workspace().tiled_layout == "scrolling"
  if not (window and scrolling) then
    return hl.exec_cmd("omarchy-hyprland-window-tiled-fullscreen-toggle")
  end

  if is_wide(window) then
    return hl.dispatch(hl.dsp.layout("colresize " .. hl.get_config("scrolling.column_width")))
  end
  local left, right = neighbours(window)
  hl.dispatch(hl.dsp.layout("colresize " .. (1 - (left + right) * peek)))
  center_between_peeks()
end)

-- Focusing a neighbour scrolls it into view; coming back must restore both peeks.
hl.on("window.active", function()
  local window = hl.get_active_window()
  local scrolling = hl.get_active_workspace().tiled_layout == "scrolling"
  if window and scrolling and not window.floating and is_wide(window) then
    center_between_peeks()
  end
end)
