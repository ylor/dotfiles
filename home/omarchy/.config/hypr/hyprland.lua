-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
omarchy_preinstalled_bindings = false

-- Replace the stock 1Password rule because its forced size flashes before auth dialogs resize.
package.loaded["default.hypr.apps.1password"] = true

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Map D3D12 descriptor heaps directly to Vulkan to reduce CPU translation overhead.
-- Check around November 2026 whether this has become the default.
hl.env("VKD3D_CONFIG", "descriptor_heap")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE", "on")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION", "render_preset_latest")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE", "on")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION", "render_preset_latest")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE", "on")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE_RENDER_PRESET_SELECTION", "render_preset_latest")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

if package.searchpath("hypr.local", package.path) then
  require("hypr.local")
end

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

o.window({ title = "^World of Warcraft.*" }, {
  fullscreen = true,
  suppress_event = "fullscreen",
})

hl.config({
  dwindle = {
    force_split = 2,
  },
})

local function set_qconsole_seed()
  hl.workspace_rule({
    workspace = "special:scratchpad",
    on_created_empty = [=[[workspace special:scratchpad silent] /bin/bash -c '
      cd "$HOME/.dotfiles" 2>/dev/null && exec omarchy-agent
      cd "$HOME" || exit
      exec omarchy-launch-tui --app-id=org.omarchy.agent "$(omarchy-default-agent)"
    ']=],
  })
end

set_qconsole_seed()
hl.on("monitor.layout_changed", set_qconsole_seed)
hl.on("monitor.focused", set_qconsole_seed)
