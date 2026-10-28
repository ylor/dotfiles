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

-- Map D3D12 descriptor heaps directly to Vulkan to reduce CPU translation overhead.
-- Check around November 2026 whether this has become the default.
hl.env("VKD3D_CONFIG", "descriptor_heap")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE", "on")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION", "render_preset_latest")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE", "on")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION", "render_preset_latest")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE", "on")
hl.env("DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE_RENDER_PRESET_SELECTION", "render_preset_latest")

-- GTK's default Vulkan renderer adds a GL->Vulkan copy per frame for GL apps
-- like Ghostty, which lags on NVIDIA. Use the GL renderer instead.
hl.env("GSK_RENDERER", "ngl")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("hypr.expand")
require("hypr.controller")

if package.searchpath("hypr.local", package.path) then
  require("hypr.local")
end

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Azeroth Survivors (Bevy) panics when it can't get a frame, which happens when the
-- window is resized out of fullscreen or hidden. Keep it fullscreen and rendering.
o.window({ initial_title = "^Azeroth Survivors$" }, {
  fullscreen = true,
  suppress_event = "fullscreen maximize",
  render_unfocused = true,
  -- Controller input doesn't reset the idle timer.
  idle_inhibit = "always",
})

-- 1Password's auth modal should hold focus and dim around it, like the polkit prompt.
-- The modal and the main window open identically: floating, "1Password", 875x600.
-- The modal shrinks within ~33ms, so hide new windows briefly and split them by width.
o.window({ class = "^com\\.onepassword\\.OnePassword$", title = "^1Password$" }, { no_anim = true })

-- The new window is still floating here, so it never finds itself.
local function tiled_onepassword()
  for _, window in ipairs(hl.get_windows()) do
    if window.class == "com.onepassword.OnePassword" and not window.floating then
      return window
    end
  end
end

hl.on("window.open", function(window)
  if window.class ~= "com.onepassword.OnePassword" then
    return
  end

  local target = "address:" .. window.address
  local function set_prop(prop, value)
    hl.dispatch(hl.dsp.window.set_prop({ prop = prop, value = value, window = target }))
  end

  set_prop("opacity", "0")

  hl.timer(function()
    local is_modal = window.size.x < 600
    if is_modal then
      set_prop("stay_focused", "1")
      set_prop("dim_around", "1")
    else
      -- Only the main window tiles. Settings and other extras float centered over it.
      local main = tiled_onepassword()
      if main then
        local x = main.at.x + (main.size.x - window.size.x) // 2
        local y = main.at.y + (main.size.y - window.size.y) // 2
        hl.dispatch(hl.dsp.window.move({ x = x, y = y, window = target }))
      else
        hl.dispatch(hl.dsp.window.float({ action = "off", window = target }))
      end
    end

    set_prop("opacity", "1")
  end, { type = "oneshot", timeout = 50 })
end)

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

-- Omarchy's qconsole.lua rewrites the whole rule on these events and resets the seed.
set_qconsole_seed()
for _, event in ipairs({
  "monitor.layout_changed",
  "monitor.focused",
  "workspace.special_active",
  "workspace.move_to_monitor",
  "window.open",
  "window.destroy",
  "window.move_to_workspace",
  "window.update_rules",
}) do
  hl.on(event, set_qconsole_seed)
end
