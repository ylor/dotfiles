-- Load Omarchy's toggles, but narrow Appearance > Window Opacity > Glassy from
-- every window to the ones Omarchy makes transparent by default, at Glassy's
-- own opacity. If Glassy stops fading ".*", this does nothing and stock Glassy applies.
local window = o.window

o.window = function(match, rules)
  if match == ".*" and rules.opacity then
    -- class = ".*" is not redundant: Hyprland 0.57.2 drops a tag-only rule on
    -- every other re-evaluation, which each title change triggers.
    match = { class = ".*", tag = "transparent-window" }

    -- qconsole dims everything behind it by 0.6, so its glass would blur a
    -- near-black backdrop.
    hl.config({ decoration = { dim_special = 0.2 } })
  end
  return window(match, rules)
end

require("default.hypr.toggles")
o.window = window
