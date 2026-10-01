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
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

local hyper = "CTRL + ALT + SUPER"

o.bind(hyper .. " + A", "Switch audio output", "omarchy-audio-output-switch", { locked = true })
o.bind(hyper .. " + V", "Volume mixer", "omarchy-shell shell toggle omarchy.audio")
o.bind(hyper .. " + UP", "Brightness up", "omarchy-brightness-display +5%", { locked = true, repeating = true })
o.bind(hyper .. " + DOWN", "Brightness down", "omarchy-brightness-display 5%-", { locked = true, repeating = true })
o.bind("ALT + mouse_up", "Brightness up", "omarchy-brightness-display +5%", { locked = true })
o.bind("ALT + mouse_down", "Brightness down", "omarchy-brightness-display 5%-", { locked = true })

hl.unbind("SUPER + W")
o.bind("SUPER + I", "Browser", { omarchy = "browser" })
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

local function volume_if_over_bar(direction)
  local cursor = hl.get_cursor_pos()
  if not cursor then return end

  for _, layer in ipairs(hl.get_layers()) do
    if layer.namespace == "omarchy-bar" and layer.mapped then
      local margin = layer.w * 0.1
      local within_x = cursor.x >= layer.x + margin and cursor.x < layer.x + layer.w - margin
      local within_y = cursor.y >= layer.y and cursor.y < layer.y + layer.h
      if within_x and within_y then
        hl.exec_cmd("omarchy-audio-output-volume " .. direction)
        return
      end
    end
  end
end

o.bind("mouse_up", "Volume up over Omarchy bar", function() volume_if_over_bar("raise") end, { locked = true, non_consuming = true })
o.bind("mouse_down", "Volume down over Omarchy bar", function() volume_if_over_bar("lower") end, { locked = true, non_consuming = true })

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
o.rebind("SUPER + E", "File manager", { launch = 'strata' })
hl.unbind("SUPER + ALT + SHIFT + F")
o.rebind("SUPER + SHIFT + E", "File manager (cwd)", { launch = 'flea --gui "$(omarchy-cmd-terminal-cwd)"' })
-- flea --default: end.

-- flea --picker: begin. Written by `flea --picker`; `flea --picker off` removes the block whole.
o.window("com.thisisgm.flea.picker", { tag = "+floating-window" })
-- flea --picker: end.
