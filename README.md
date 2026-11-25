# FluorineOS Desktop

`Debian 13 Trixie | Hyprland 0.55+ | x86_64`

> **Looking for the FluorineOS ISO?** Official installation images are published in the
> main repository:
> [FluorineOS/fluorine Releases](https://github.com/FluorineOS/fluorine/releases/latest).

`fluorine-desktop` installs the Hyprland session, the AMOLED desktop themes, and the
`flr-*` command line utilities used by FluorineOS. Configuration is written to
`/etc/skel/.config`, so a newly created user receives the desktop on first login.

## Package Contents

| Path | Description |
| --- | --- |
| `/etc/skel/.config/hypr/hyprland.lua` | Native Hyprland 0.55 Lua configuration |
| `/etc/skel/.config/hypr/hypridle.conf` | Idle policy: dim at 5 min, lock at 10 min, battery suspend at 20 min |
| `/etc/skel/.config/hypr/hyprlock.conf` | Lock screen with OLED burn-in protection |
| `/etc/skel/.config/hypr/.luarc.json` | Lua language server settings |
| `/etc/skel/.config/waybar/config.jsonc` | Waybar layout with Fluorine status icons |
| `/etc/skel/.config/waybar/style.css` | Waybar stylesheet |
| `/etc/skel/.config/kitty/kitty.conf` | Kitty terminal theme |
| `/etc/skel/.config/fuzzel/fuzzel.ini` | Fuzzel launcher theme with Fluorine icons |
| `/etc/skel/.config/swaync/style.css` | SwayNotificationCenter theme |
| `/etc/skel/.config/kanshi/config` | Display profiles applied on output hotplug |
| `/usr/share/fluorineos/shaders/night.glsl` | Warm low-blue-light display shader |
| `/usr/share/fluorineos/shaders/mono.glsl` | Grayscale focus-mode display shader |
| `/usr/bin/flr-osd` | Transient confirmation for volume, mic, backlight, and Wi-Fi changes |
| `/usr/bin/flr-settings` | Native GTK4 and libadwaita settings panel |
| `/usr/bin/flr-store` | Curated application hub with GTK4 and libadwaita interface |
| `/usr/bin/flr-sync` | Declarative dotfile and state manager with GTK4 companion interface |
| `/usr/bin/flr-config` | Apply the geometry and idle state in `~/.config/fluorine/config.lua` |
| `/etc/skel/.config/fluorine/config.lua` | Editable gaps, border width, and idle lock timeout |
| `/usr/share/applications/fluorine-settings.desktop` | Desktop entry with the flr-settings icon |
| `/usr/share/applications/flr-store.desktop` | Desktop entry for the application hub |
| `/usr/share/applications/flr-sync.desktop` | Desktop entry for the dotfile and state manager |
| `/usr/bin/flr-shader` | Display shader cycle, picker, and restore |
| `/usr/bin/flr-wall` | Wallpaper picker, next, set, and restore |
| `/usr/bin/flr-shot` | Interactive area screenshot |
| `/usr/bin/flr-keys` | Keybinding reference dialog |
| `/usr/bin/flr-doctor` | Hardware, session, and service diagnostic report |
| `/usr/bin/flr-onboard` | One-time first-login keybinding guide |
| `/usr/bin/flr-tui` | Run a terminal interface in a floating Kitty window |
| `/usr/bin/flr-bt` | Bluetooth manager launcher |
| `/usr/bin/flr-power` | Power profile status and cycling for Waybar |
| `/usr/bin/flr-ctl` | Unified Fuzzel system menu |
| `/usr/bin/flr-update` | APT refresh, upgrade summary, and reboot report |
| `/usr/bin/flr-snapshot` | Btrfs snapshot create, list, and rollback |
| `/usr/bin/flr-mode` | Work, focus, and present workstation profiles |
| `/usr/bin/flr-box` | Rootless Podman and Distrobox development boxes |
| `/etc/xdg/mimeapps.list` | System-wide default handlers for files, images, PDFs, and archives |
| `/etc/skel/.config/mimeapps.list` | Per-user copy of the same default handlers |

## Daily-Driver Utilities

Every file action has one application. Thunar is the file manager, backed by
`thunar-volman` for removable media, `thunar-archive-plugin` so right-click archive
extraction reaches File Roller, Tumbler for thumbnails, and the gvfs backends for trash,
network shares, and MTP devices. File Roller handles zip, tar, tar-compressed, and 7z
archives with `unzip`, `zip`, and `xz-utils` installed. swayimg is the Wayland image
viewer, Zathura with the Poppler plugin reads PDFs in dark recolor mode, Mousepad edits
plain text, galculator is the calculator, and btop is the system monitor.

Default handlers come from `/etc/xdg/mimeapps.list`, with a copy in
`/etc/skel/.config/mimeapps.list` so a new user owns their own list: directories open in
Thunar, PDFs in Zathura, PNG, JPEG, WebP, GIF, and SVG images in swayimg, zip, tar,
tar-compressed, and 7z archives in File Roller, and plain text in Mousepad. The user copy
wins once the user changes a default through the desktop, and the system list stays as
the fallback.

`xdg-user-dirs-update` runs at session start. On the first login it creates `~/Desktop`,
`~/Documents`, `~/Downloads`, `~/Pictures`, and `~/Videos` with the localized names from
`/etc/xdg/user-dirs.defaults`, so the Thunar sidebar, file dialogs, and the wallpaper
picker all point at real folders. Later logins leave existing folders untouched.

`SUPER + E` opens Thunar. galculator floats centred at 360x480, File Roller at 680x460,
and btop, which `flr-ctl` starts as System Monitor with its own window class, at 900x560,
so none of them takes a tiled workspace slot.

## Desktop Behavior

The session starts `hypridle`, `kanshi`, `cliphist` through `wl-paste --watch`, and
`flr-onboard` from the Hyprland autostart hook.

| Feature | Binding or trigger |
| --- | --- |
| Lock session | `SUPER + L`, or 10 minutes idle |
| Screen dim | 5 minutes idle |
| Suspend | 20 minutes idle while discharging |
| Clipboard history | `SUPER + C` |
| Volume up, down, mute | `XF86AudioRaiseVolume`, `XF86AudioLowerVolume`, `XF86AudioMute` |
| Microphone mute | `XF86AudioMicMute` |
| Brightness | `XF86MonBrightnessUp`, `XF86MonBrightnessDown` |
| Wi-Fi and Ethernet | Click the Waybar network module, or run `flr-tui nmtui` |
| Bluetooth pairing | Click the Waybar Bluetooth module, or run `flr-bt` |
| Power profile | Click the Waybar power module; it cycles power-saver, balanced, performance |
| System menu | `SUPER + Escape`, or click the Waybar SYS indicator |
| Display shader | `SUPER + Shift + N` cycles off, night, mono |
| Wallpaper | `SUPER + W` opens the picker; `flr-wall next` advances |
| Workstation mode | `SUPER + M`, or click the Waybar mode badge |
| External display | Connect an HDMI or DisplayPort monitor; kanshi applies a profile |

The network module calls `nmtui` from NetworkManager inside a floating Kitty window, so
Wi-Fi, Ethernet, VPN, and connection editing stay in one interface. The Bluetooth module
opens `blueman-manager`; when that package is absent it falls back to `bluetoothctl` in the
same floating terminal.

`flr-power` reads `powerprofilesctl` and degrades cleanly on hardware without an ACPI
platform profile driver: the module shows `PWR N/A` and a click reports that profiles are
unavailable instead of failing.

Every clickable Waybar module carries a tooltip that names both its click and scroll
actions, for example `Left-click: Network settings | Right-click: Toggle Wi-Fi`. Hovering
raises the module fill from the bar surface to `#141920` and switches its 1.5px underline
from the hairline `#1c2229` to the lime accent, so the pointer target is unambiguous
before the click lands. Volume and power also respond to the scroll wheel.

State-changing actions never run silently. `flr-osd` applies a volume, microphone,
backlight, or Wi-Fi change and then posts a transient `swaync` card with the new value;
`flr-mode`, `flr-wall`, and `flr-shader` report their result the same way. All of them
share one replacing notification id per tool, so holding a volume key updates a single
card instead of stacking a column.

`flr-ctl` collects the hardware and session actions in one Fuzzel menu: network settings
through `nmtui`, the Bluetooth manager, `wdisplays`, the audio mixer, power profile
cycling, the keybinding cheatsheet, `flr-doctor` in a persistent terminal, the snapshot
list in a persistent terminal, and lock, suspend, reboot, and shutdown. Every row
carries its themed icon, so the menu matches the Waybar slots. The Waybar SYS indicator
opens the same menu, and a right click runs `flr-update` in a terminal.

`flr-store` is the curated application hub: a GTK4 and libadwaita window that groups
verified developer tools, browsers, and media software into Development, Web, Multimedia,
and System Utilities categories, and installs them through apt, Flatpak, or a flr-box
container. Installs run on worker threads and report progress through the inline status
pill and toasts. The hub opens with `SUPER + S` and from the `Application Hub` row in the
`flr-ctl` Fuzzel menu.

`flr-sync` is the declarative dotfile and state manager. It exports `~/.config/fluorine`,
`~/.config/hypr`, `~/.config/waybar`, `.bashrc`, and `.bash_aliases` into versioned gzip
archives under `$XDG_STATE_HOME/fluorine/sync/snapshots`, mirrors the same files into a
local Git repository, and can push that repository to a remote configured with
`flr-sync remote set URL` and `flr-sync backup --push`. `flr-sync status` compares the live
files with a snapshot and reports `ok`, `changed`, and `missing` entries. `flr-sync restore
--dry-run` previews conflicts, and a real restore creates one `flr-sync-pre-restore` Btrfs
snapshot through snapper before writing anything. The GTK4 companion interface exposes
Backup State, Preview Changes, Restore Configs, View Sync Status, and Push to Remote, with
restore requiring a second confirmation after the preview. The Backup State, Restore
Configs, and View Sync Status actions also live in the Fuzzel control menu.

`flr-update` refreshes APT metadata, lists the incoming FluorineOS and security packages,
runs the upgrade, and reports whether `/var/run/reboot-required` was written. `flr-update
--check` performs the refresh and listing without installing anything. When `/` is on
Btrfs, it creates a `pre-update` snapshot through `flr-snapshot` before applying the
upgrade, and prints the rollback command afterwards.

`flr-snapshot` drives snapper on the `root` configuration: `create [label]` writes a
read-only snapshot and refreshes the GRUB menu when a snapshot generator is installed,
`list` prints an aligned table of ids, timestamps, and descriptions, and
`rollback <id>` sets an earlier snapshot as the default root subvolume and prints the
reboot steps. Installations created by Calamares mount `@`, `@home`, and `@snapshots`, so
a rollback replaces the system subvolume without touching `/home` or the snapshot store.

`flr-mode` switches the whole workstation between three profiles in one compositor
batch, and reports the active profile as `WORK`, `FOCUS`, or `PRESENT` in the Waybar badge.
`work` restores the session defaults with gaps at 4 and 6, a two-pixel border, full
opacity, notifications on, and the idle daemon running. `focus` removes gaps, drops the
border to one pixel, dims inactive windows to 0.85, hides Waybar, and enables do not
disturb. `present` widens the outer gaps to 14, holds full contrast, keeps notifications
quiet, stops `hypridle` so the screen never locks, and nudges `kanshi` to reapply output
profiles. The profile is remembered in `~/.local/state/fluorine/mode`, so the badge is
correct after a reload.

`flr-box` keeps language runtimes and toolchains out of the host APT database by running
them in rootless Podman containers managed through Distrobox. `flr-box init debian` (or
`arch` and `fedora`) creates a box, `flr-box enter` opens a shell, `flr-box export <binary>`
publishes a container command into `~/.local/bin`, and `flr-box list` shows the boxes.

`flr-wall` lists `/usr/share/backgrounds/fluorine/` and `~/Pictures/Wallpapers/` in a
Fuzzel picker, applies the choice through `swaybg`, and stores the path in
`~/.local/state/fluorine/wallpaper`. With no saved choice it applies the shipped 4K
wordmark wallpaper `wall1.png`, which is also the lock screen default; `wall2.png` and
`wall3.png` ship beside it. The Hyprland start hook runs `flr-wall restore`, so the
session comes back on the same wallpaper instead of a bare color, and every switch rewrites
the `path` line of the `background` block in `~/.config/hypr/hyprlock.conf` so the lock
screen follows the desktop. `flr-wall set <path>` and `flr-wall next` cover scripted use.
When `fluorine-artwork` is absent the switcher falls back to `swaybg -c '#000000'`.

`flr-settings` is the graphical counterpart to these commands: a native GTK4 and
libadwaita window with a navigation sidebar and six sections. Appearance holds the
wallpaper grid, the display shader, and the window geometry; Workstation switches the
profile, the idle lock timeout, and the first-login cheat sheet; Displays reads
`hyprctl monitors` and applies a scale; Network and Bluetooth report live state and
launch `nmtui`, `bluetui`, or `blueman-manager` in floating windows; Audio drives the
default sink and source through `wpctl`; System and Snapshots shows the OS and hardware
summary with the snapshot list. The sidebar uses the symbolic icon variants, so each
glyph follows the resting, hover, and selected row color. Nothing is reimplemented:
every control calls the same `flr-*` command the keyboard workflow uses. `SUPER + comma`
opens the panel, it is the first entry in `flr-ctl`, and Hyprland floats it at 880x600
in the centre of the screen.

`flr-config` owns `~/.config/fluorine/config.lua`, a short key = value file holding
`gaps_in`, `gaps_out`, `border_size`, and `idle_lock`. `flr-config apply` pushes the gaps and
border width to Hyprland and rewrites the hyprlock listener timeout in
`~/.config/hypr/hypridle.conf`, restarting `hypridle` when the value changed. A timeout of 0
clears that listener's `on-timeout`, which is how hypridle disables it. The Hyprland start
hook applies the file at login, so window geometry and the idle timeout survive a restart.
Hyprland only draws integer borders, so the 1.5px choice is rendered as 2px.

`flr-shader` drives Hyprland's `decoration:screen_shader` and keeps the three
states honest: `off` loads no shader at all and stays color-accurate, `night` runs a warm
low-blue-light pass for late sessions, and `mono` desaturates the session to Rec. 709
luminance for focus work. The choice is remembered in `~/.local/state/fluorine/shader`
and reapplied at login, so a restart does not silently drop back to color. A window
without a running compositor is reported rather than silently ignored.

The session animation set is deliberately narrow: two bounded cubic-bezier curves, one
decelerating ease-out and one with a flatter tail, drive 150-200ms window, fade, layer, and
workspace transitions. Neither curve leaves the `[0, 1]` value range, so nothing overshoots
or springs. Waybar, Fuzzel, and SwayNC share one surface language: a 32px raised carbon bar
with a hairline bottom border, a lime underline instead of a lime fill on the active
workspace, 1.5px hairline borders on panels, cards, and tooltips, and 8px internal padding.

Waybar status slots pair a 16px icon from the Fluorine theme with the native module:
mode, system, and power carry the icon inline, while Bluetooth, network, audio, battery,
and clock use a separate icon module beside the native text. Fuzzel enables application
icons and the same theme, and every row in the `flr-ctl`, `flr-mode`, `flr-shader`, and
`flr-wall` pickers carries its icon through the Rofi extended dmenu protocol. The
settings sidebar uses the symbolic variants, so GTK recolors each glyph for the resting,
hover, and selected states.

`kanshi` watches output events. The shipped profile matches every output, keeping the
preferred mode, automatic placement, and unity scale, so docking and undocking do not
require manual `hyprctl` commands. Use `wdisplays` for interactive layout adjustments and
`hyprctl monitors` to read connector names before writing explicit profiles.

The brightness keys and the idle dim step discard errors when no backlight device is
present, which is the normal case in a virtual machine.

## Package

| Field | Value |
| --- | --- |
| Name | `fluorine-desktop` |
| Version | `0.13.0` |
| Architecture | `all` |

Runtime dependencies are declared by the package: `hyprland`, `hypridle`, `hyprlock`,
`waybar`, `kitty`, `fuzzel`, `sway-notification-center`, `swaybg`, `grim`, `slurp`,
`wl-clipboard`, `cliphist`, `brightnessctl`, `wireplumber`, `jq`, `libnotify-bin`,
`network-manager`, `bluez`, `blueman`, `power-profiles-daemon`, `kanshi`,
`wdisplays`, `pulsemixer`, `pavucontrol`, `btrfs-progs`, `snapper`, `podman`, and
`distrobox`. `nmtui` ships inside `network-manager`. `flr-shader` needs nothing beyond
`hyprland` for `hyprctl`; the picker uses `fuzzel` and degrades to a status line without it.

## Install

The FluorineOS APT repository is configured by `fluorine-keyring`. Hyprland and its
companion tools come from `trixie-backports`, so enable that suite and pin it before
installing. Without the pin, the `libxkbcommon` versions required by Hyprland are held at
the `trixie` release and the install fails to resolve.

```sh
echo 'deb http://deb.debian.org/debian trixie-backports main' \
  | sudo tee /etc/apt/sources.list.d/trixie-backports.list

sudo tee /etc/apt/preferences.d/fluorineos-backports.pref >/dev/null <<'EOF'
Package: hyprland* hypridle* hyprlock* libaquamarine* libhypr* xdg-desktop-portal-hyprland wayland-protocols libxkbcommon* libxkbregistry0
Pin: release n=trixie-backports
Pin-Priority: 900
EOF

sudo apt-get update
sudo apt-get install fluorine-desktop
```

Verify the selection before installing with `apt-cache policy hyprland libxkbcommon0`. Both
candidates must come from `trixie-backports`.

## Build

Requires `dpkg-dev` and `debhelper` on Debian 13 `amd64`.

```sh
git clone https://github.com/FluorineOS/fluorine-desktop.git
cd fluorine-desktop
dpkg-buildpackage -us -uc -b
dpkg-deb -c ../fluorine-desktop_0.13.0_all.deb
```

The built `.deb` is written to the parent directory.

## License

Released under the MIT License. See [LICENSE](LICENSE) for the full text.

Source: [FluorineOS/fluorine-desktop](https://github.com/FluorineOS/fluorine-desktop)
