#!/bin/sh
# https://github.com/typecraft-dev/crucible

sudo gum spin --title="waka waka" -- pacman -S --noconfirm fish gum

if exist gsettings; then
  gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
fi && echo "you got gnomed!"
