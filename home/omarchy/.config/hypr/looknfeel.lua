-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 2,
    gaps_out = 2,
    border_size = 1,

    -- Change to niri-like side-scrolling layout.
    -- layout = "scrolling",
  },
})

hl.workspace_rule({
  workspace = "w[tv1]",
  no_border = true,
})

hl.window_rule({
  match = { float = true },
  border_size = 1,
})

hl.window_rule({
  match = { class = "1Password", float = true },
  border_size = 0,
})

hl.window_rule({
  match = { class = "steam", title = "Steam" },
  float = false,
  border_size = 0,
  no_shadow = true,
  decorate = false,
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 0,
    rounding_power = 4,
    glow = {
      enabled = true,
      range = 3,
      render_power = 1,
      color = hl.get_config("general.col.active_border"),
      color_inactive = "rgba(00000000)",
    },

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

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- https://wiki.hypr.land/configuring/core/advanced-configuration/events/
-- Use a solid bar while the qconsole is open.
local restore_bar_transparency = false

hl.on("workspace.special_active", function(workspace)
  local qconsole_open = workspace and workspace.name == "special:scratchpad"

  if qconsole_open then
    local pipe = assert(io.popen("omarchy shell shell listShellConfig | jq -r '.bar.transparent'"))
    restore_bar_transparency = pipe:read("*l") == "true"
    pipe:close()

    if restore_bar_transparency then
      hl.exec_cmd("omarchy bar transparent false")
    end
    return
  end

  if not restore_bar_transparency then return end

  hl.exec_cmd("omarchy bar transparent true")
  restore_bar_transparency = false
end)
