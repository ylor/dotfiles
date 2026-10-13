-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 2,
    gaps_out = 2,
    -- border_size = 1,

    -- Change to niri-like side-scrolling layout.
    -- layout = "scrolling",
  },
})

hl.workspace_rule({
  workspace = "w[tv1]s[false]",
  no_border = true,
  gaps_out = 4,
})

hl.window_rule({
  match = { class = "steam", title = "Steam" },
  float = false,
  decorate = false,
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    -- Use round window corners.
    -- rounding = 1,
    -- rounding_power = 4,

    -- -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
    dim_inactive = true,
    dim_strength = 0.10,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- Opt another application in to Omarchy's standard transparency.
-- Find its class with: hyprctl clients
-- o.transparent_window("my-app")
-- o.transparent_window("my-app", "0.9 0.85") -- Custom active/inactive opacity.
