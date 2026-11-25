local hyper = "CTRL + ALT + SUPER"

hl.config({
  binds = {
    movefocus_cycles_fullscreen = true,
  },
})

---------------------------------------------------------------------------
-- Launchers and apps
---------------------------------------------------------------------------

hl.unbind("SUPER + W")
o.rebind("SUPER + I", "Browser", { omarchy = "browser" })
o.rebind("SUPER + SHIFT + N", "Browser (private)", { omarchy = "browser --private" })

o.rebind("ALT + SPACE", "omacast launcher", hl.dsp.global("omacast:toggle"))
o.rebind("SUPER + SPACE", "omacast launcher", hl.dsp.global("omacast:toggle"))
o.bind(hyper .. " + SPACE", "Omarchy menu", { menu = "root" })
o.bind(hyper .. " + RETURN", "Agent in dotfiles", "cd ~/.dotfiles && omarchy-agent --pick")

-- flea --default: begin. Written by `flea --default`; `flea --default off` removes the block whole.
hl.unbind("SUPER + SHIFT + F")
o.rebind("SUPER + E", "File manager", { launch = 'flea --gui' })
hl.unbind("SUPER + ALT + SHIFT + F")
o.rebind("SUPER + SHIFT + E", "File manager (cwd)", { launch = 'flea --gui "$(omarchy-cmd-terminal-cwd)"' })
-- flea --default: end.

-- flea --picker: begin. Written by `flea --picker`; `flea --picker off` removes the block whole.
o.window("com.thisisgm.flea.picker", { tag = "+floating-window" })
-- flea --picker: end.

---------------------------------------------------------------------------
-- System
---------------------------------------------------------------------------

o.bind(hyper .. " + L", "Lock system", "omarchy-system-lock")

---------------------------------------------------------------------------
-- Audio
---------------------------------------------------------------------------

o.bind(hyper .. " + A", "Switch audio output", "omarchy-audio-output-switch", { locked = true })
o.bind(hyper .. " + V", "Volume mixer", { panel = "omarchy.audio" })

-- Step volume onto the next multiple of 5, so a level set by hand (e.g. 37%)
-- snaps back to the 5% grid. Shell, because reading the volume in Lua blocks Hyprland.
local read_volume = [[v=$(LC_ALL=C pactl get-sink-volume "$(omarchy-audio-output-sink)" | grep -oP '[0-9]+(?=%)' | head -n1); ]]
local volume_up = read_volume .. [[omarchy-audio-output-volume +$((5 - v % 5))]]
local volume_down = read_volume .. [[omarchy-audio-output-volume -$(((v + 4) % 5 + 1))]]

o.rebind("XF86AudioRaiseVolume", "Volume up", volume_up, { locked = true, repeating = true })
o.rebind("XF86AudioLowerVolume", "Volume down", volume_down, { locked = true, repeating = true })

---------------------------------------------------------------------------
-- Mouse wheel
---------------------------------------------------------------------------

-- Default 300ms drops most wheel notches on scroll binds like volume. Applies to
-- every wheel bind, including ALT + wheel brightness under Display.
hl.config({ binds = { scroll_event_delay = 30 } })

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

-- Left + right click together over the same area switches the audio output.
-- A held button expires after a second in case Hyprland skips its release.
local mouse_held = {}
local function chord_button(button, other)
  local key = "mouse:" .. button
  o.bind(key, "Switch audio output over Omarchy bar (with mouse:" .. other .. ")", function()
    mouse_held[button] = true
    hl.timer(function() mouse_held[button] = nil end, { timeout = 1000, type = "oneshot" })
    if mouse_held[other] and over_bar() then hl.exec_cmd("omarchy-audio-output-switch") end
  end, { locked = true, non_consuming = true })
  hl.bind(key, function() mouse_held[button] = nil end,
    { release = true, transparent = true, ignore_mods = true, non_consuming = true, locked = true })
end
chord_button(272, 273)
chord_button(273, 272)

-- The low scroll_event_delay above would let one wheel flick skip several
-- workspaces, so workspace scrolling waits 300ms itself.
local workspace_scroll_cooling = false

local function scroll_workspace(direction)
  if workspace_scroll_cooling then return end
  workspace_scroll_cooling = true
  hl.timer(function() workspace_scroll_cooling = false end, { timeout = 300, type = "oneshot" })
  hl.dispatch(hl.dsp.focus({ workspace = direction }))
end

o.rebind("SUPER + mouse_down", "Scroll active workspace forward", function() scroll_workspace("m+1") end)
o.rebind("SUPER + mouse_up", "Scroll active workspace backward", function() scroll_workspace("m-1") end)

---------------------------------------------------------------------------
-- Display: brightness and monitor input
---------------------------------------------------------------------------

o.bind(hyper .. " + UP", "Brightness up", { brightness = "raise" }, { locked = true, repeating = true })
o.bind(hyper .. " + DOWN", "Brightness down", { brightness = "lower" }, { locked = true, repeating = true })
o.bind(hyper .. " + BACKSPACE", "Brightness 0%", "omarchy-brightness-display 0%", { locked = true })
o.bind("ALT + mouse_up", "Brightness up", { brightness = "raise" }, { locked = true })
o.bind("ALT + mouse_down", "Brightness down", { brightness = "lower" }, { locked = true })

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
  if brightness_hold then brightness_hold:set_enabled(false); brightness_hold = nil end
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

-- The LG ignores standard input switching (VCP 0x60), so use its private 0xF4: 0x90 = HDMI-1, 0xD0 = DP-1.
-- It also can't report the current input, so remember the last choice here.
local on_hdmi = false
o.bind(hyper .. " + I", "Toggle monitor input DP-1/HDMI-1", function()
  on_hdmi = not on_hdmi
  local code = on_hdmi and "0x90" or "0xD0"
  hl.exec_cmd("ddcutil --sn 409NTHM0S137 --noverify --i2c-source-addr=0x50 setvcp 0xF4 " .. code)
end, { locked = true })

---------------------------------------------------------------------------
-- Windows: cycling and minimizing
---------------------------------------------------------------------------

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

o.rebind("SUPER + TAB", "Next window in active workspace", function() cycle_window(true) end)
o.rebind("SUPER + SHIFT + TAB", "Previous window in active workspace", function() cycle_window(false) end)

-- Floating workspaces keep Omarchy's dock minimize; workspace-modes.lua tags
-- their windows. Tiled workspaces have no dock, so SUPER+M toggles one window
-- in and out of a stash of its own.
local function on_floating_workspace(window)
  for _, tag in ipairs(window and window.tags or {}) do
    if tag:find("^omarchy%-floating%-workspace") then return true end
  end
  return false
end

o.rebind("SUPER + M", "Minimize window", function()
  if on_floating_workspace(hl.get_active_window()) then
    hl.exec_cmd("omarchy-hyprland-window-minimize")
    return
  end

  local stash = hl.get_workspace("special:stash")
  if stash then
    hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace(), window = stash.last_window }))
  else
    hl.dispatch(hl.dsp.window.move({ workspace = "special:stash", follow = false }))
  end
end)

---------------------------------------------------------------------------
-- Workspaces
---------------------------------------------------------------------------

o.rebind("ALT + TAB", "Next workspace", hl.dsp.focus({ workspace = "m+1" }))
o.rebind("ALT + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "m-1" }))

---------------------------------------------------------------------------
-- Layout: tiling / scrolling
---------------------------------------------------------------------------

o.rebind("SUPER + Home", "Rebalance window split", hl.dsp.layout("splitratio 1.0 exact"))

-- Toggles the column to 0.9 wide so a neighbour peeks in from the edge; alone,
-- fullscreen_on_one_column draws it full. looknfeel.lua's auto-sizing leaves
-- columns of 0.9 or wider alone, so this sticks. Toggling back restores the width it had before.
local WIDE = 0.9
local width_before_widen = {} -- by stable_id: addresses get reused

local function toggle_wide_column()
  local active = hl.get_active_window()
  local column = active and active.layout and active.layout.column
  if not column then return end

  -- Widths are 32-bit floats, so 0.9 reads back as 0.8999999762.
  if column.width > WIDE - 0.01 then
    local previous = width_before_widen[active.stable_id] or hl.get_config("scrolling.column_width")
    width_before_widen[active.stable_id] = nil
    hl.dispatch(hl.dsp.layout("colresize " .. previous))
    -- Shrinking doesn't pull the view back, so empty space would be left. Focusing
    -- the first column scrolls to the start; refocusing this one then scrolls just
    -- far enough to show it.
    local first = active
    for _, window in ipairs(active.workspace:get_windows()) do
      if not window.floating and window.at.x < first.at.x then first = window end
    end
    hl.dispatch(hl.dsp.focus({ window = "address:" .. first.address }))
    hl.dispatch(hl.dsp.focus({ window = "address:" .. active.address }))
  else
    width_before_widen[active.stable_id] = column.width
    hl.dispatch(hl.dsp.layout("colresize " .. WIDE))
  end
end

o.bind("SUPER + SHIFT + F", "Toggle wide column", toggle_wide_column)
