-- FluorineOS 0.0.1 Hyprland configuration.
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
})

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
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- FluorineOS utilities
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("flr-shot"))
hl.bind(mainMod .. " + slash",     hl.dsp.exec_cmd("flr-keys"))

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
