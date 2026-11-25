-- TODO: Remove this file, and its require in hyprland.lua, once a Hyprland
-- release with scrolling:focus_fit_method = 2 ("clamped_center") is installed:
--   https://github.com/hyprwm/Hyprland/pull/16899 (commit 53f36f3b2, after v0.57.2)
--
-- clamped_center brings a focused column to the middle of the screen like
-- "center", but never scrolls past either end of the tape:
--   offset = clamp(start - (usable - size) / 2, 0, max(0, extent - usable))
--
-- Unlike upstream, which leaves a soft or click focus alone when the column is
-- already fully visible, any focus re-centers here (see wants_move).
--
-- 0.57.2 has no way to set the tape offset from Lua, so this keeps the
-- built-in "fit" (which already clamps a negative offset to 0), then runs
-- "layout center" and, past the right end, "layout move +<px>" back to it.
-- Only the default "right" scrolling direction is handled.

local function version_at_least(major, minor)
  local maj, min = tostring(hl.version()):match("^(%d+)%.(%d+)")
  maj, min = tonumber(maj), tonumber(min)
  if not maj then return false end
  return maj > major or (maj == major and min >= minor)
end

-- Hovering never scrolls the tape. Hyprland's default (0.4) scrolls to a
-- hovered column once 40% of the screen width of it shows, which pushes the
-- focused column off screen. Clicks and keyboard focus still bring it in.
hl.config({ scrolling = { follow_min_visible = 1.0 } })

if version_at_least(0, 58) then
  hl.config({ scrolling = { focus_fit_method = 2 } })
  return
end

hl.config({ scrolling = { focus_fit_method = 1 } })

-- Desktop::eFocusReason (src/desktop/state/FocusState.hpp in v0.57.2)
local R = {
  FFM = 1 << 0,
  KEYBIND = 1 << 1,
  CLICK_DOWN = (1 << 5) | (1 << 4),
  DESKTOP_STATE_CHANGE = 1 << 7,
  SWITCH_TO_WINDOW_HARD = 1 << 9,
  UNMAP_WINDOW_TILING = 1 << 13,
  NEW_WINDOW = 1 << 16,
  GHOSTS = 1 << 17,
}

local busy = false

local function scrolling_tile(window)
  if not window or window.floating or (window.fullscreen or 0) ~= 0 then return nil end
  local workspace = window.workspace
  if not workspace or workspace.tiled_layout ~= "scrolling" then return nil end
  if hl.get_config("scrolling.direction") ~= "right" then return nil end
  local column = window.layout and window.layout.column
  if not column or not column.index then return nil end
  return workspace, column
end

-- The tiled area as CScrollingAlgorithm::usableArea() sees it, in global
-- logical coordinates: the monitor minus reserved space minus gaps_out.
-- Workspace rules that override gaps_out are not taken into account.
local function usable_area(window)
  local monitor = window.monitor or hl.get_active_monitor()
  if not monitor then return nil end
  local scale = monitor.scale or 1
  local width = monitor.width / scale
  if (monitor.transform or 0) % 2 == 1 then width = monitor.height / scale end
  local reserved = monitor.reserved or {}
  local gaps = hl.get_config("general.gaps_out")
  if type(gaps) ~= "table" then gaps = { left = tonumber(gaps) or 0, right = tonumber(gaps) or 0 } end
  local left = monitor.x + (reserved.left or 0) + (gaps.left or 0)
  local right = monitor.x + width - (reserved.right or 0) - (gaps.right or 0)
  return left, right
end

-- Any focus change re-centers the column, even one already fully on screen,
-- except focus that follows the mouse: centering the window under the cursor
-- would slide another one under it and hand focus on. Those keep Hyprland's
-- own fit. A click is handled by the mouse:272 release bind below, since focus
-- already moved on the press.
local function wants_move(reason)
  if reason == R.FFM or reason == R.CLICK_DOWN then return false end
  if hl.get_config("scrolling.follow_focus") ~= 0 then return true end
  return reason == R.NEW_WINDOW or reason == R.KEYBIND or reason == R.GHOSTS
    or reason == R.DESKTOP_STATE_CHANGE or reason == R.UNMAP_WINDOW_TILING
    or reason == R.SWITCH_TO_WINDOW_HARD
end

local function clamped_center(window)
  local workspace, column = scrolling_tile(window)
  if not workspace then return end

  local left, right = usable_area(window)
  if not left then return end
  local usable = right - left

  local widths, count = {}, 0
  for _, other in ipairs(workspace:get_windows()) do
    local c = not other.floating and other.layout and other.layout.column
    if c and c.index then
      widths[c.index] = c.width
      count = math.max(count, c.index + 1)
    end
  end
  if count < 2 and hl.get_config("scrolling.fullscreen_on_one_column") then return end

  local start, extent = 0, 0
  for i = 0, count - 1 do
    local size = usable * (widths[i] or 0)
    if i < column.index then start = start + size end
    extent = extent + size
  end
  -- Narrower than the screen: Hyprland centers the whole tape itself.
  if extent <= usable then return end

  local size = usable * column.width
  local centered = start - (usable - size) / 2
  local limit = extent - usable

  busy = true
  hl.dispatch(hl.dsp.layout("center"))
  if centered > limit + 0.5 then
    -- "move" refocuses whatever column ends up in the middle; give focus back.
    hl.dispatch(hl.dsp.layout(string.format("move +%.3f", centered - limit)))
    local active = hl.get_active_window()
    if not active or active.address ~= window.address then
      hl.dispatch(hl.dsp.focus({ window = "address:" .. window.address }))
    end
  end
  busy = false
end

local function later(window)
  local address = window.address
  hl.timer(function()
    local active = hl.get_active_window()
    if active and active.address == address then clamped_center(active) end
  end, { timeout = 1, type = "oneshot" })
end

hl.on("window.active", function(window, reason)
  if busy or not scrolling_tile(window) then return end
  if wants_move(reason) then later(window) end
end)

-- Releasing a click on the focused tiled window. Non-consuming, so the click
-- still reaches the window; bindings.lua has its own mouse:272 release bind.
hl.bind("mouse:272", function()
  if busy or hl.get_config("scrolling.follow_focus") == 0 then return end
  local window = hl.get_active_window()
  local cursor = hl.get_cursor_pos()
  if not window or not cursor or not scrolling_tile(window) then return end
  local x, y = window.at.x, window.at.y
  if cursor.x < x or cursor.x > x + window.size.x or cursor.y < y or cursor.y > y + window.size.y then return end
  later(window)
end, { release = true, transparent = true, ignore_mods = true, non_consuming = true })

-- Leaving fullscreen or maximized puts the column back with focus_fit_method.
hl.on("window.fullscreen", function(window)
  if busy or not window or (window.fullscreen or 0) ~= 0 then return end
  later(window)
end)
