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
        -- 4px geometry. Enough to read as intentional on a dark wallpaper,
        -- small enough that the hard-edged AMOLED surface language survives.
        rounding         = 4,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- A short, strictly black shadow. It separates stacked windows on dark
        -- wallpapers without tinting the palette: monochrome black cannot
        -- introduce a hue, so the four design tokens stay authoritative.
        shadow = {
            enabled        = true,
            range          = 12,
            render_power   = 3,
            color          = "rgba(000000ff)",
            color_inactive = "rgba(000000ff)",
            offset         = "0 3",
            sharp          = false,
        },

        -- Blur is reserved for the layer rules below, where Waybar, Fuzzel,
        -- and SwayNC panels sit over window content. Window surfaces stay
        -- opaque, so text contrast is untouched.
        blur = {
            enabled           = true,
            size              = 4,
            passes            = 2,
            new_optimizations = true,
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

-- Two calibrated cubic-beziers, both monotonic and bounded by [0, 1] on the
-- value axis, so nothing overshoots, springs, or bounces.
--
--   fluorineOut      cubic-bezier(0.16, 1.0, 0.30, 1.0)  decelerating ease-out
--   fluorineOutFast  cubic-bezier(0.25, 1.0, 0.50, 1.0)  same shape, flatter tail
--
-- Hyprland derives an animation duration from 1 / speed, so the speeds below map
-- to roughly 150-200ms: 6.6 is about 150ms, 5.0 is 200ms.
hl.curve("fluorineOut",     { type = "bezier", points = { {0.16, 1.0}, {0.30, 1.0} } })
hl.curve("fluorineOutFast", { type = "bezier", points = { {0.25, 1.0}, {0.50, 1.0} } })

hl.animation({ leaf = "global",         enabled = true, speed = 6.6, bezier = "fluorineOut" })
hl.animation({ leaf = "border",         enabled = true, speed = 6.6, bezier = "fluorineOut" })
hl.animation({ leaf = "windows",        enabled = true, speed = 6.6, bezier = "fluorineOut" })
hl.animation({ leaf = "windowsIn",      enabled = true, speed = 6.6, bezier = "fluorineOut",     style = "popin 97%" })
hl.animation({ leaf = "windowsOut",     enabled = true, speed = 5.6, bezier = "fluorineOutFast", style = "popin 97%" })
hl.animation({ leaf = "fade",           enabled = true, speed = 6.0, bezier = "fluorineOutFast" })
hl.animation({ leaf = "fadeIn",         enabled = true, speed = 6.6, bezier = "fluorineOutFast" })
hl.animation({ leaf = "fadeOut",        enabled = true, speed = 5.6, bezier = "fluorineOutFast" })
-- Layer fade-in is what Fuzzel, Waybar popups, and SwayNC use.
hl.animation({ leaf = "layers",         enabled = true, speed = 6.0, bezier = "fluorineOutFast" })
hl.animation({ leaf = "layersIn",       enabled = true, speed = 6.6, bezier = "fluorineOutFast", style = "fade" })
hl.animation({ leaf = "layersOut",      enabled = true, speed = 5.6, bezier = "fluorineOutFast", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",   enabled = true, speed = 6.6, bezier = "fluorineOutFast" })
hl.animation({ leaf = "fadeLayersOut",  enabled = true, speed = 5.6, bezier = "fluorineOutFast" })
-- Workspace switches slide rather than scale.
hl.animation({ leaf = "workspaces",     enabled = true, speed = 5.6, bezier = "fluorineOutFast", style = "slide" })
hl.animation({ leaf = "workspacesIn",   enabled = true, speed = 6.0, bezier = "fluorineOutFast", style = "slide" })
hl.animation({ leaf = "workspacesOut",  enabled = true, speed = 5.6, bezier = "fluorineOutFast", style = "slide" })

------------------------
---- LAYER SURFACES ----
------------------------

-- Blur only the shell chrome that floats over window content. SwayNC ships two
-- layer namespaces, so both are matched. ignore_alpha = 0 is the 0.55 spelling
-- of the older ignorezero rule: fully transparent pixels stay unblurred instead
-- of smearing the compositor background into the panel edge. Blur stays subtle
-- (size 4, two passes) so panel text keeps full contrast against #0a0d10.
hl.layer_rule({
    name  = "fluorine-waybar",
    match = { namespace = "^waybar$" },
    blur        = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name  = "fluorine-fuzzel",
    match = { namespace = "^fuzzel$" },
    blur        = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name  = "fluorine-swaync",
    match = { namespace = "^swaync-control-center$|^swaync-notification-window$" },
    blur        = true,
    ignore_alpha = 0,
})

---------------------
---- WINDOW RULES ----
---------------------

-- FluorineOS Settings opens as a centred floating panel. Its two-pane layout is
-- sized for a dialog, so tiling it into a workspace would waste the sidebar.
hl.window_rule({
    name   = "fluorine-settings",
    match  = { class = "^(org\\.fluorineos\\.Settings|flr-settings)$" },
    float  = true,
    center = true,
    size   = { 880, 600 },
})

-- galculator draws a fixed-size keypad, so it floats centred at the size its
-- layout expects instead of taking a tiled workspace slot.
hl.window_rule({
    name   = "fluorine-calculator",
    match  = { class = "^(?i)galculator$" },
    float  = true,
    center = true,
    size   = { 360, 480 },
})

-- File Roller is a transient archive window opened from Thunar. Floating it
-- keeps the file manager layout intact while the archive is inspected.
hl.window_rule({
    name   = "fluorine-archive-manager",
    match  = { class = "^(?i)(org\\.gnome\\.FileRoller|file-roller)$" },
    float  = true,
    center = true,
    size   = { 680, 460 },
})

-- flr-ctl opens btop with its own window class, so the system monitor floats
-- at a readable size and tiles are left alone.
hl.window_rule({
    name   = "fluorine-monitor",
    match  = { class = "^(?i)flr-btop$" },
    float  = true,
    center = true,
    size   = { 900, 560 },
})

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
    -- Create ~/Desktop, ~/Documents, ~/Downloads, ~/Pictures, and ~/Videos on
    -- first login so the Thunar sidebar and file dialogs have real targets.
    -- The command is idempotent and does nothing once the folders exist.
    hl.exec_cmd("xdg-user-dirs-update")
    -- Reapply the geometry and idle timeout saved in
    -- ~/.config/fluorine/config.lua before the rest of the shell starts.
    hl.exec_cmd("flr-config apply")
    -- Apply the saved wallpaper, falling back to the shipped grid wallpaper, so
    -- the desktop matches the lock screen from the first frame.
    hl.exec_cmd("flr-wall restore")
    -- Reapply the display shader chosen before the last logout, so the look
    -- survives a restart instead of silently resetting to color-accurate.
    hl.exec_cmd("flr-shader restore")
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
-- Cycle the display shader off, night, mono (color-accurate by default).
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("flr-shader cycle"))
-- Wallpaper picker across the shipped set and ~/Pictures/Wallpapers.
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("flr-wall"))
hl.bind(mainMod .. " + slash",     hl.dsp.exec_cmd("flr-keys"))
-- Unified system menu: network, Bluetooth, display, audio, power, and session.
hl.bind(mainMod .. " + Escape",    hl.dsp.exec_cmd("flr-ctl"))
-- Graphical control panel. The same actions stay reachable from flr-ctl.
hl.bind(mainMod .. " + comma",     hl.dsp.exec_cmd("flr-settings"))
hl.bind(mainMod .. " + M",         hl.dsp.exec_cmd("flr-mode"))

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
