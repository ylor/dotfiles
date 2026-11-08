-- AmberConsole neon for Hyprland. See DESIGN.md § Hyprland.
--
-- The focused window is an .ac-panel: stroke-bright border plus --ac-glow-box,
-- which is `0 0 8px rgba(halo-1, 0.32)` at neon's spread of 1. Every other
-- window is an .ac-panel--dim: stroke-dim border, glow at the faint drive tier
-- (0.32 x 0.41 = 0.13). Hyprland takes a single shadow layer, so only the 8px
-- outer glow is carried; the 10px inset layer has no equivalent.

local emit_100 = "rgb(ffa86d)" -- stroke on the focused window / latched group tab
local emit_90 = "rgb(ff6b08)" -- fill: the active group tab in inverse video
local emit_70 = "rgb(dd5800)" -- ink-dim, the focus-ring tone: the focused window that refuses a group
local emit_50 = "rgb(ab4500)" -- stroke-dim: unfocused windows
local emit_30 = "rgb(5b2500)" -- ink-trace: a window that refuses a group (disabled border)
local on_fill = "rgb(1e0c00)" -- text on a lit tab
local screen = "rgb(100600)"
local screen_well = "rgb(060200)"

-- halo-1 (255,120,30) at --ac-glow-box alpha, and at the faint tier.
local glow_box = "rgba(ff781e52)" -- 0.32
local glow_box_dim = "rgba(ff781e21)" -- 0.13

hl.config({
  general = {
    col = {
      active_border = emit_100,
      inactive_border = emit_50,
      nogroup_border = emit_30,
      nogroup_border_active = emit_70,
    },
  },

  group = {
    col = {
      border_active = emit_100,
      border_inactive = emit_50,
      border_locked_active = emit_100,
      border_locked_inactive = emit_50,
    },

    -- Group tabs follow components/tabs.css: the selected tab is latched, so it
    -- is inverse video; the others are ink on the panel. A locked group drives
    -- its latched tab to fill-bright and recesses the rest into the well.
    groupbar = {
      text_color = on_fill,
      text_color_inactive = emit_90,
      text_color_locked_active = on_fill,
      text_color_locked_inactive = emit_90,
      col = {
        active = emit_90,
        inactive = screen,
        locked_active = emit_100,
        locked_inactive = screen_well,
      },
    },
  },

  decoration = {
    shadow = {
      enabled = true,
      range = 8,
      render_power = 3,
      color = glow_box,
      color_inactive = glow_box_dim,
    },
  },

  -- Painted only where no wallpaper covers the output.
  misc = {
    background_color = screen,
  },
})
