-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

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

local function volume_if_over_bar(direction)
  local cursor = hl.get_cursor_pos()
  if not cursor then return end

  for _, layer in ipairs(hl.get_layers()) do
    local is_bar = layer.namespace == "omarchy-bar" and layer.mapped
    local within_x = cursor.x >= layer.x and cursor.x < layer.x + layer.w
    local within_y = cursor.y >= layer.y and cursor.y < layer.y + layer.h
    if is_bar and within_x and within_y then
      hl.exec_cmd("omarchy-audio-output-volume " .. direction)
      return
    end
  end
end

o.bind("mouse_up", "Volume up over Omarchy bar", function() volume_if_over_bar("raise") end, { locked = true, non_consuming = true })
o.bind("mouse_down", "Volume down over Omarchy bar", function() volume_if_over_bar("lower") end, { locked = true, non_consuming = true })
