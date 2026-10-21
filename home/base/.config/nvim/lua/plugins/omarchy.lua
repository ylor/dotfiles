-- Omarchy's plugin specs, opted into one by one.
-- Left out on purpose: all-themes, disable-news-alert, lualine-transparent.
local omarchy = require("config.omarchy")

return {
  omarchy.load("lua/plugins/omarchy-theme-hotreload.lua"),
  omarchy.load("lua/plugins/snacks-animated-scrolling-off.lua"),
}
