dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

omarchy_preinstalled_bindings = false

require("default.hypr.omarchy")

require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

require("hypr.expandr")
require("hypr.workspace-fix")

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

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE", "on")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION", "render_preset_latest")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE", "on")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION", "render_preset_latest")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE", "on")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE_RENDER_PRESET_SELECTION", "render_preset_latest")
hl.env("PROTON_ENABLE_WAYLAND", "1")
-- Map D3D12 descriptor heaps directly to Vulkan to reduce CPU translation overhead.
-- Still opt-in as of vkd3d-proton 3.1 (GE-Proton11-12, checked Nov 2026).
hl.env("VKD3D_CONFIG", "descriptor_heap")

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
  match = { class = "^helium$" },
  no_auto_hdr = true,
})

hl.window_rule({
  match = { tag = "chromium-based-browser", workspace = "w[tv1]s[false]", float = false },
  border_size = 1,
})

hl.window_rule({
  match = { class = "^wowb?\\.exe$" },
  fullscreen = true,
  -- Out of fullscreen it would float, since it asks for a fixed size.
  float = false,
})

-- Azeroth Survivors (Bevy) panics when it can't get a frame, which happens when the
-- window is resized out of fullscreen or hidden. Keep it fullscreen and rendering.
o.window({ initial_title = "^Azeroth Survivors$" }, {
  fullscreen = true,
  suppress_event = "fullscreen maximize",
  render_unfocused = true,
  -- Controller input doesn't reset the idle timer.
  idle_inhibit = "always",
})

hl.layer_rule({ match = { namespace = "^omacast$" }, no_anim = true, animation = "none" })

--------------
---- MISC ----
--------------

-- Start omarchy-agent in ~/.dotfiles instead of ~/Work. Covers qconsole only, not
-- Omarchy's Agent bind, the agents panel or the app launcher.
local exec_cmd = hl.exec_cmd
hl.exec_cmd = function(cmd, rules)
  if type(cmd) == "string" and (cmd == "omarchy-agent" or cmd:find("^omarchy%-agent ")) then
    cmd = "cd ~/.dotfiles && " .. cmd
  end
  return exec_cmd(cmd, rules)
end
