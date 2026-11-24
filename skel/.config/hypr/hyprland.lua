-- FluorineOS 0.1.1 Hyprland configuration.
--
-- Native Hyprland 0.55+ Lua API. Deprecated hyprlang directives and removed
-- 0.54 options are not used anywhere in this file.
--
-- Design tokens:
--   background        #000000
--   elevated surface  #0a0d10
--   inactive border   #1c2229
--   primary accent    #b4f03a
--   selection         #2a3812
--   foreground        #e2e8f0
--   muted text        #6e7681
--
-- Hyprland parses colors as rgba(RRGGBBAA), so each CSS-style token above
-- maps directly: #b4f03aff becomes rgba(b4f03aff).

local mainMod = "SUPER"

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        border_size = 2,
        gaps_in     = 4,
        gaps_out    = 6,
        layout      = "dwindle",

        col = {
            active_border   = { colors = { "rgba(b4f03aff)" } },
            inactive_border = "rgba(1c2229ff)",
        },
    },

    decoration = {
        rounding         = 6,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- FluorineOS disables drop shadows everywhere.
        shadow = {
            enabled = false,
        },

        blur = {
            enabled = true,
            size    = 5,
            passes  = 2,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        -- Pure AMOLED black compositor background.
        background_color        = "rgba(000000ff)",
        disable_hyprland_logo   = true,
        force_default_wallpaper = 0,
    },

    -- Legacy X11 clients keep a 1:1 pixel scale, so they stay crisp on
    -- fractional-scaled outputs instead of being bitmap-scaled by XWayland.
    xwayland = {
        force_zero_scaling = true,
    },
})

---------------------------
---- ENVIRONMENT VARS -----
---------------------------

-- Qt 6 applications use the qt6ct palette that fluorine-artwork installs, so
-- they get the AMOLED Void surfaces and lime accent instead of a light theme.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Electron and Chromium clients select their Wayland backend automatically
-- rather than falling back to XWayland.
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Cursor theme and size, shared by Wayland and XWayland clients.
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

---------------
---- MONITORS --
---------------

-- Fallback rule for every output that has no explicit rule: preferred mode,
-- automatic placement, unity scale. Hyprland applies the closest matching
-- rule per display, so this covers internal and external panels alike.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- HiDPI panels: replace the fallback above with one of these, then adjust any
-- legacy application that draws too small.
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.5 })

--------------------
---- ANIMATIONS ----
--------------------

-- Crisp exponential ease-out with zero bounce: both control points stay
-- inside [0, 1], so no animation overshoots. The speeds below land in the
-- 0.16s-0.20s range.
hl.curve("fluorineEaseOut", { type = "bezier", points = { {0.16, 1.0}, {0.3, 1.0} } })

hl.animation({ leaf = "global",     enabled = true, speed = 5.0, bezier = "fluorineEaseOut" })
hl.animation({ leaf = "border",     enabled = true, speed = 4.4, bezier = "fluorineEaseOut" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4.6, bezier = "fluorineEaseOut" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.6, bezier = "fluorineEaseOut" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4.0, bezier = "fluorineEaseOut" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4.2, bezier = "fluorineEaseOut" })
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 4.2, bezier = "fluorineEaseOut" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 4.0, bezier = "fluorineEaseOut" })
hl.animation({ leaf = "layers",     enabled = true, speed = 4.4, bezier = "fluorineEaseOut" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.4, bezier = "fluorineEaseOut" })

---------------------
---- AUTOSTART ------
---------------------

-- Hyprland 0.55 replaces the hyprlang exec-once directive with the
-- hyprland.start event.
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("lxpolkit")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swaybg -c '#000000'")
    -- Apply the kanshi profile whenever outputs change, so docking an external
    -- monitor reconfigures the layout without manual hyprctl commands.
    hl.exec_cmd("kanshi")
    -- Clipboard history: cliphist stores every text and image selection.
    hl.exec_cmd("wl-paste --watch cliphist store")
    -- First interactive login shows the keybinding cheat sheet once.
    hl.exec_cmd("flr-onboard")
end)

----------------------
---- KEYBINDINGS -----
----------------------

-- Applications
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("fuzzel"))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd("thunar"))

-- Window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Session
-- hypridle also locks after 10 minutes of inactivity; both paths use the
-- same lock screen.
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Clipboard history: pick a stored entry, decode it, and put it back on the
-- clipboard so SUPER + V pastes it.
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(
    "sh -c 'cliphist list | fuzzel --dmenu --prompt=Clip: | cliphist decode | wl-copy'"))

-- Hardware media keys. wpctl addresses the default sink and source, so the
-- bindings follow the active output and microphone.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

-- Brightness keys. Virtual machines and desktops without a backlight have no
-- brightness device, so both bindings discard the error and change nothing.
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(
    "sh -c 'brightnessctl -q set 5%+ 2>/dev/null || true'"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(
    "sh -c 'brightnessctl -q set 5%- 2>/dev/null || true'"))

-- FluorineOS utilities
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("flr-shot"))
hl.bind(mainMod .. " + slash",     hl.dsp.exec_cmd("flr-keys"))
-- Unified system menu: network, Bluetooth, display, audio, power, and session.
hl.bind(mainMod .. " + Escape",    hl.dsp.exec_cmd("flr-ctl"))

-- Move focus with the arrow keys.
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move focus with the developer HJKL cluster. SUPER + L is reserved for
-- hyprlock, so the right direction lives on SUPER + semicolon.
hl.bind(mainMod .. " + H",         hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J",         hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K",         hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + semicolon", hl.dsp.focus({ direction = "right" }))

-- Switch workspaces with SUPER + [1-9] and move windows with SUPER + SHIFT.
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
