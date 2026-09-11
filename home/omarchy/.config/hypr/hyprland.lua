-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

hl.config({
  dwindle = {
    force_split = 2,
  },
})

-- Override Agent default working directory
local function set_qconsole_seed()
  hl.workspace_rule({
    workspace = "special:scratchpad",
    on_created_empty = [=[[workspace special:scratchpad silent] /bin/bash -c '
      cd "$HOME/.dotfiles" 2>/dev/null && exec /usr/bin/omarchy-agent

      # The stock launcher redirects HOME to Work, so bypass it for the fallback.
      cd "$HOME" || exit 1
      agent=$(/usr/bin/omarchy-default-agent)
      exec /usr/bin/omarchy-launch-tui --app-id=org.omarchy.agent \
        "${agent:?Choose default agent with: omarchy default agent <name>}"
    ']=],
  })
end

set_qconsole_seed()

-- Omarchy restores its seed when refitting the console.
hl.on("monitor.layout_changed", set_qconsole_seed)
hl.on("monitor.focused", set_qconsole_seed)
