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
| `/etc/skel/.config/waybar/config.jsonc` | Waybar layout |
| `/etc/skel/.config/waybar/style.css` | Waybar stylesheet |
| `/etc/skel/.config/kitty/kitty.conf` | Kitty terminal theme |
| `/etc/skel/.config/fuzzel/fuzzel.ini` | Fuzzel launcher theme |
| `/etc/skel/.config/swaync/style.css` | SwayNotificationCenter theme |
| `/etc/skel/.config/kanshi/config` | Display profiles applied on output hotplug |
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
| External display | Connect an HDMI or DisplayPort monitor; kanshi applies a profile |

The network module calls `nmtui` from NetworkManager inside a floating Kitty window, so
Wi-Fi, Ethernet, VPN, and connection editing stay in one interface. The Bluetooth module
opens `blueman-manager`; when that package is absent it falls back to `bluetoothctl` in the
same floating terminal.

`flr-power` reads `powerprofilesctl` and degrades cleanly on hardware without an ACPI
platform profile driver: the module shows `PWR N/A` and a click reports that profiles are
unavailable instead of failing.

`flr-ctl` collects the hardware and session actions in one Fuzzel menu: network settings
through `nmtui`, the Bluetooth manager, `wdisplays`, the audio mixer, power profile cycling,
the keybinding cheatsheet, `flr-doctor` in a persistent terminal, the snapshot list in a
persistent terminal, and lock, suspend, reboot, and shutdown. The Waybar SYS indicator opens the same menu, and a right click runs
`flr-update` in a terminal.

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
| Version | `0.4.0` |
| Architecture | `all` |

Runtime dependencies are declared by the package: `hyprland`, `hypridle`, `hyprlock`,
`waybar`, `kitty`, `fuzzel`, `sway-notification-center`, `swaybg`, `grim`, `slurp`,
`wl-clipboard`, `cliphist`, `brightnessctl`, `wireplumber`, `jq`, `libnotify-bin`,
`network-manager`, `bluez`, `blueman`, `power-profiles-daemon`, `kanshi`,
`wdisplays`, `pulsemixer`, `pavucontrol`, `btrfs-progs`, and `snapper`. `nmtui` ships
inside `network-manager`.

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
dpkg-deb -c ../fluorine-desktop_0.1.2_all.deb
```

The built `.deb` is written to the parent directory.

## License

Released under the MIT License. See [LICENSE](LICENSE) for the full text.

Source: [FluorineOS/fluorine-desktop](https://github.com/FluorineOS/fluorine-desktop)
