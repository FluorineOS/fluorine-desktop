# FluorineOS Desktop

Desktop configuration package for FluorineOS 0.0.1.

## Contents

- Hyprland 0.55+ native Lua configuration
- Waybar, Kitty, Fuzzel, and SwayNotificationCenter themes
- hypridle and hyprlock configuration
- Hyprland session entry through the upstream start-hyprland wrapper
- flr-* CLI utilities: flr-shot, flr-keys, flr-doctor

## Package

- Name: fluorine-desktop
- Version: 0.0.3
- Architecture: all

## Build

```sh
dpkg-buildpackage -us -uc -b
```

This repository is part of the FluorineOS project.
