hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 2,
    layout = "scrolling",
  },
  misc = {
    -- A new window drops the fullscreen one out of fullscreen instead of
    -- taking fullscreen over from it (Omarchy's default, 1).
    on_focus_under_fullscreen = 2,
  },
  decoration = {
    rounding = 1,
    rounding_power = 4,
  },
})

-- Scrolling columns are Omarchy's column_width (just under half) so a third
-- window peeks in from the edge. With exactly two there is nothing to peek, so
-- they fill the screen instead. A column the user widened to 0.9 or more is left
-- alone. Its stored width is the user's, unlike a lone column that
-- fullscreen_on_one_column only draws full.
local function auto_sized_count()
  local workspace = hl.get_active_workspace()
  if not workspace or workspace.tiled_layout ~= "scrolling" then return 0 end

  local tiled = 0
  for _, window in ipairs(workspace:get_windows()) do
    if not window.floating then
      local column = window.layout and window.layout.column
      -- SUPER+SHIFT+F's peeking width (0.9, bindings.lua) counts as widened. Widths
      -- are 32-bit floats, so 0.9 reads back as 0.8999999762.
      if column and column.width > 0.89 then return 0 end
      tiled = tiled + 1
    end
  end
  return tiled
end

local function fill_two_columns()
  if auto_sized_count() == 2 then
    hl.dispatch(hl.dsp.layout("fit visible"))
  end
end

-- Shrink before the third column is placed so the view scrolls to show it with
-- the first column peeking in. A window that opens floating is undone by window.open.
-- The opening window is already counted here.
hl.on("window.open_early", function()
  if auto_sized_count() == 3 then
    hl.dispatch(hl.dsp.layout("colresize all " .. hl.get_config("scrolling.column_width")))
  end
end)
hl.on("window.open", fill_two_columns)
hl.on("window.destroy", fill_two_columns)
hl.on("window.move_to_workspace", fill_two_columns)
