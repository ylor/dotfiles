-- Borders are strokes (emit-100 focus / emit-30 trace); shadows are glow,
-- so they take the halo triples: halo-1 core, halo-3 deep/outermost.
-- Border values mirror hyprland_active_border / hyprland_inactive_border in
-- colors.toml, which the shell reads.
local active_border_color = "rgb(ffa86d)"
local active_shadow_color = "rgb(ff781e)"
local inactive_border_color = "rgba(5b250099)"
local inactive_shadow_color = "rgba(ff660022)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    }
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    shadow = {
      enabled = true,
      range = 6,
      render_power = 4,
      color = active_shadow_color,
      color_inactive = inactive_shadow_color,
    },
  },
})

-- The Quake console already sits apart over the dimmed workspace (and has no
-- border), so the halo shadow would read as a stray glow around it.
o.window({ workspace = "special:qconsole" }, { no_shadow = true })
