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

o.bind("SUPER + CTRL + ALT + UP", "Brightness up", "omarchy-brightness-display +5%", { locked = true, repeating = true })
o.bind("SUPER + CTRL + ALT + DOWN", "Brightness down", "omarchy-brightness-display 5%-", { locked = true, repeating = true })
o.bind("ALT + mouse_up", "Brightness up", "omarchy-brightness-display +5%", { locked = true })
o.bind("ALT + mouse_down", "Brightness down", "omarchy-brightness-display 5%-", { locked = true })

hl.unbind("SUPER + W")
o.bind("SUPER + I", "Browser", { omarchy = "browser" })
o.rebind("SUPER + Home", "Rebalance window split", hl.dsp.layout("splitratio 1.0 exact"))

local function volume_if_over_bar(direction)
  local cursor = hl.get_cursor_pos()
  if not cursor then return end

  for _, layer in ipairs(hl.get_layers()) do
    local is_bar = layer.namespace == "omarchy-bar" and layer.mapped
    local horizontal_margin = layer.w * 0.1
    local inner_left = layer.x + horizontal_margin
    local inner_right = layer.x + layer.w - horizontal_margin
    local within_x = cursor.x >= inner_left and cursor.x < inner_right
    local within_y = cursor.y >= layer.y and cursor.y < layer.y + layer.h
    if is_bar and within_x and within_y then
      hl.exec_cmd("omarchy-audio-output-volume " .. direction)
      return
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
    hl.dispatch(hl.dsp.window.clear_tags({
      window = "tag:minimized",
    }))
  else
    hl.dispatch(hl.dsp.window.tag({
      tag = "minimized",
      window = hl.get_active_window(),
    }))
    hl.dispatch(hl.dsp.window.move({
      workspace = "special:minimized",
      follow = false,
    }))
  end
end)

-- flea --default: begin. Written by `flea --default`; `flea --default off` removes the block whole.
hl.unbind("SUPER + SHIFT + F")
o.rebind("SUPER + E", "File manager", { launch = 'flea --gui' })
hl.unbind("SUPER + ALT + SHIFT + F")
o.rebind("SUPER + SHIFT + E", "File manager (cwd)", { launch = 'flea --gui "$(omarchy-cmd-terminal-cwd)"' })
-- flea --default: end.
