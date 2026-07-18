-- https://wiki.hypr.land/Configuring/Start/
-- https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua

require("env")
require("animations")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "1.5",
})

hl.monitor({
    output = "desc:LG",
    mode = "preferred",
    position = "auto",
    scale = "2",
    bitdepth = 10,
    cm = "wide",
    -- sdr_eotf = "default",
    sdr_min_luminance = "0"
})

----------------------
---- APPLICATIONS ----
----------------------

-- Set programs that you use
local terminal    = "ghostty"
local fileManager = "dolphin"
local menu        = "hyprlauncher"

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia")
    --hl.exec_cmd(terminal)
    --hl.exec_cmd("nm-applet")
    --hl.exec_cmd("waybar & hyprpaper & firefox")
end)

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

hl.config({
  ecosystem = {
    enforce_permissions = true,
  },
})

hl.permission("/usr/bin/noctalia", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 10,

        border_size      = 1,

        col              = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing    = false,

        layout           = "dwindle",
    },

    decoration = {
        rounding         = 16,
        rounding_power   = 4,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 0.666,

        shadow           = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },

        blur             = {
            enabled  = true,
            size     = 3,
            passes   = 3,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        focus_on_activate = true,
    },

    xwayland = {
        force_zero_scaling = true
    }
})

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 2, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 2, gaps_in = 0 })
hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    -- rounding    = 0,
})
hl.window_rule({
    name  = "no-gaps-f1",
    match = { float = false, workspace = "f[1]" },
    border_size = 0,
    -- rounding    = 0,
})

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        force_split = 2,
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,   -- Set to 0 or 1 to disable the anime mascot wallpapers
        background_color        = "rgb(000000)",
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "ctrl:nocaps",
        kb_rules     = "",

        follow_mouse = 1,

        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad     = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name = "pulsar-8k-dongle-gen.2",
    -- sensitivity = -0.25,
    accel_profile = "flat",
})

---------------------
---- KEYBINDINGS ----
---------------------
-- https://wiki.hypr.land/Configuring/Basics/Binds/ for more

local mod = {
    main = "SUPER",
    win  = "CTRL",
    alt  = "ALT",
    hypr = "CTRL + ALT + SUPER",
}

local function app(class, command)
    return function()
        local special_workspace = hl.get_active_special_workspace()
        local window = hl.get_window("class:^(" .. class .. ")$")

        if special_workspace then
            hl.dispatch(hl.dsp.exec_raw(command))
        else
            hl.dispatch(
                window
                    and hl.dsp.focus({ window = window })
                    or hl.dsp.exec_raw(command)
            )
        end
    end
end

hl.bind(
    mod.main .. " + I",
    app("helium", "helium-browser")
)

hl.bind(mod.main .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod.hypr .. " + COMMA", hl.dsp.exec_cmd("noctalia msg settings-toggle"))
hl.bind(mod.hypr .. " + L", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind(mod.main .. " + X", hl.dsp.submap("session_menu"))
hl.bind(mod.main .. " + Q", hl.dsp.window.close())
hl.bind(mod.main .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mod.main .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod.main .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mod.alt .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mod.main .. " + P", hl.dsp.window.pseudo())
hl.bind(mod.main .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mod.main .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod.main .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod.main .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod.main .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mod.hypr .. " + up", hl.dsp.exec_cmd("noctalia msg brightness-up"))
hl.bind(mod.hypr .. " + down", hl.dsp.exec_cmd("noctalia msg brightness-down"))

-- Session menu submap (muscle memory)
hl.bind(mod.main .. " + X", function()
    hl.dispatch(hl.dsp.exec_cmd([[
        noctalia msg notification-show \
        '{"app_name":"Hyprland","summary":"Session menu active","body":"Press U to open the session panel","urgency":"low","timeout_ms":3000,"icon":"power"}'
    ]]))
    hl.dispatch(hl.dsp.submap("session_menu"))
end)

hl.define_submap("session_menu", "reset", function()
    hl.bind("U", function()
        hl.dispatch(hl.dsp.exec_cmd(
            "noctalia msg panel-toggle session"
        ))
        hl.dispatch(hl.dsp.submap("reset"))
    end)

    hl.bind("catchall", hl.dsp.submap("reset"))
end)


-- Workspaces
hl.workspace_rule({ workspace = "1", persistent = true })
hl.workspace_rule({ workspace = "2", persistent = true })
hl.workspace_rule({ workspace = "3", persistent = true })
-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 9 do
    local key = i -- 10 maps to key 0
    hl.bind(mod.win .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod.win .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mod.main .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod.main .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mod.main .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod.main .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mod.main .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod.main .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name           = "suppress-maximize-events",
    match          = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$",
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Noctalia Settings
hl.window_rule({
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size = { 1080, 920 },
})
-- For Noctalia Color templates
require("noctalia").apply_theme()
