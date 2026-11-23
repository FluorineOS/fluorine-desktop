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
| `/etc/skel/.config/hypr/hypridle.conf` | Idle timeout and lock policy |
| `/etc/skel/.config/hypr/hyprlock.conf` | Lock screen with OLED burn-in protection |
| `/etc/skel/.config/hypr/.luarc.json` | Lua language server settings |
| `/etc/skel/.config/waybar/config.jsonc` | Waybar layout |
| `/etc/skel/.config/waybar/style.css` | Waybar stylesheet |
| `/etc/skel/.config/kitty/kitty.conf` | Kitty terminal theme |
| `/etc/skel/.config/fuzzel/fuzzel.ini` | Fuzzel launcher theme |
| `/etc/skel/.config/swaync/style.css` | SwayNotificationCenter theme |
| `/usr/bin/flr-shot` | Interactive area screenshot |
| `/usr/bin/flr-keys` | Keybinding reference dialog |
| `/usr/bin/flr-doctor` | Desktop environment diagnostic check |

## Package

| Field | Value |
| --- | --- |
| Name | `fluorine-desktop` |
| Version | `0.0.3` |
| Architecture | `all` |

Runtime dependencies are declared by the package: `hyprland`, `hypridle`, `hyprlock`,
`waybar`, `kitty`, `fuzzel`, `sway-notification-center`, `swaybg`, `grim`, `slurp`,
`wl-clipboard`, `jq`, and `libnotify-bin`.

## Install

The FluorineOS APT repository is configured by `fluorine-keyring`. After it is installed:

```sh
sudo apt-get update
sudo apt-get install fluorine-desktop
```

## Build

Requires `dpkg-dev` and `debhelper` on Debian 13 `amd64`.

```sh
git clone https://github.com/FluorineOS/fluorine-desktop.git
cd fluorine-desktop
dpkg-buildpackage -us -uc -b
dpkg-deb -c ../fluorine-desktop_0.0.3_all.deb
```

The built `.deb` is written to the parent directory.

## License

Source: [FluorineOS/fluorine-desktop](https://github.com/FluorineOS/fluorine-desktop)
