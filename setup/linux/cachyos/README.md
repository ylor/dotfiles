# Theme Change Guide

Use this file when you create or revise a cohesive desktop theme.

Edit only the paths and values in this guide.

## Noctalia

- Edit `home/linux/distros/cachyos/.config/noctalia/palettes/<palette>.json`.
  - Set every `m*` color under `dark` and `light`.
  - Set every `terminal.normal` and `terminal.bright` color.
  - Set the terminal foreground, background, selection, and cursor colors.
- Edit `home/linux/distros/cachyos/.config/noctalia/config.toml`.
  - Set `theme.custom_palette` to the palette name.
  - Set `theme.source` to `custom`.
  - Set `wallpaper.fill_color`.
  - Set the color values in `wallpaper.default.path` and `wallpaper.last.path`.

## Hyprland

- Edit `home/linux/distros/cachyos/.config/hypr/hyprland.lua`.
  - Set the `org.gnome.desktop.interface color-scheme` value for dark or light applications.
  - Set the `org.gnome.desktop.interface icon-theme` value to a matching icon theme.
  - Set `misc.background_color` to the fallback desktop color.

## Ghostty

- Edit `home/base/.config/ghostty/config`.
  - Set `theme` to the required file name.
  - Set `background` because this value overrides the theme background.
- Edit `home/base/.config/ghostty/themes/<theme>`.
  - Set palette entries `0` through `15`.
  - Set the background, foreground, cursor, selection, and cursor-text colors.
- Edit `home/linux/distros/cachyos/.config/ghostty/style.css`.
  - Set `bg` for the native tab interface.
  - Set `fg` for the native tab interface.

## Neovim

- Edit `home/base/.config/nvim_bak/lua/kickstart/plugins/colorscheme.lua`.
  - Set all `nano_*_color` values in the custom `amber.dark` function.
  - Set all colors in its `ansi` table.
  - Change the variant name consistently if the theme is not amber.
