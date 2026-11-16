-- Appearance > Window Opacity > Glassy, limited to windows that are already
-- transparent under the default setting. Glassy fades every window (".*"); keep
-- its blur and value, but only for the transparent-window ruleset (terminals,
-- Nautilus, 1Password, ... and anything toggled with Super+Backspace).
-- Must load after default.hypr.toggles so these rules win.
local paths = require("default.hypr.paths")

local glassy = io.open(paths.state_home .. "/omarchy/toggles/hypr/window-glassy.lua", "r")
if not glassy then
  return
end
glassy:close()

o.window(".*", { opacity = "1 1" })
o.window({ tag = "transparent-window" }, { opacity = "0.75 0.75" })

-- qconsole dims everything behind a special workspace by 0.6, so its glass
-- blurs a near-black backdrop. Dim less so the console reads as glass.
hl.config({ decoration = { dim_special = 0.2 } })
