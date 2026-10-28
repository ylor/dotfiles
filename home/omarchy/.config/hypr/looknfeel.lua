-- Change the default Omarchy look'n'feel.

local function theme_color(key)
  local file = io.open(os.getenv("HOME") .. "/.local/state/omarchy/current/theme/colors.toml")
  local text = file and file:read("a") or ""
  if file then file:close() end
  return text:match(key .. '%s*=%s*"#(%x+)"') or "000000"
end

local shadow = theme_color("darker_background")

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 2,
    gaps_out = 2,
    -- border_size = 1,

    -- Change to niri-like side-scrolling layout.
    layout = "scrolling",
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 2,
    rounding_power = 4,

    -- -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
    dim_inactive = true,
    dim_strength = 0.10,

    -- Dim around windows with dim_around, like the 1Password auth modal.
    -- Matches Omarchy's polkit backdrop.
    dim_around = 0.5,

    -- Subtle shadow for floating windows, close to end-4.
    -- A big single-layer shadow looks muddy.
    shadow = {
      enabled = true,
      range = 20,
      render_power = 3,
      color = "rgba(" .. shadow .. "50)",
      color_inactive = "rgba(" .. shadow .. "25)",
    },
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- A lone tiled window on a regular workspace needs no border to stand out.
hl.workspace_rule({
  workspace = "w[tv1]s[false]",
  no_border = true,
  gaps_out = 4,
})

-- Floating windows: rounder corners and no border.
hl.window_rule({
  match = { float = true },
  rounding = 8,
  border_size = 0,
})

-- No rule can enable shadows per window, so they are on globally and off for tiled windows.
hl.window_rule({
  match = { float = false },
  no_shadow = true,
})

-- Omarchy floats Steam; tile the main window and drop its decorations instead.
hl.window_rule({
  match = { class = "steam", title = "Steam" },
  float = false,
  decorate = false,
})

-- Keep WoW launched through Steam's Battle.net fullscreen, ignoring its own requests.
hl.window_rule({
  match = { class = "^steam_app_battlenet$", title = "^World of Warcraft$" },
  fullscreen = true,
  suppress_event = "fullscreen maximize",
})

hl.window_rule({
  match = { class = "^wowb?\\.exe$" },
  -- app thinks it is fullscreen, but the compositor keeps it a tiled column
  fullscreen_state = "0 2",
  suppress_event = "fullscreen maximize",
})

-- Opt another application in to Omarchy's standard transparency.
-- Find its class with: hyprctl clients
-- o.transparent_window("my-app")
-- o.transparent_window("my-app", "0.9 0.85") -- Custom active/inactive opacity.

-- Scrolling columns are 0.49 wide so a third window peeks in from the edge.
-- With exactly two there is nothing to peek, so they fill the screen instead.
local function scrolling_tiled_count()
  local workspace = hl.get_active_workspace()
  if not workspace or workspace.tiled_layout ~= "scrolling" then return 0 end

  local tiled = 0
  for _, window in ipairs(workspace:get_windows()) do
    if not window.floating then tiled = tiled + 1 end
  end
  return tiled
end

local function fill_two_columns()
  if scrolling_tiled_count() == 2 then
    hl.dispatch(hl.dsp.layout("fit visible"))
  end
end

-- Shrink before the third column is placed so the view scrolls to show it with
-- the first column peeking in. A window that opens floating is undone by window.open.
-- The opening window is already counted here.
hl.on("window.open_early", function()
  if scrolling_tiled_count() == 3 then
    hl.dispatch(hl.dsp.layout("colresize all 0.49"))
  end
end)
hl.on("window.open", fill_two_columns)
hl.on("window.destroy", fill_two_columns)
hl.on("window.move_to_workspace", fill_two_columns)
