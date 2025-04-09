#!/bin/sh
# https://github.com/typecraft-dev/crucible

pacman -S --noconfirm fish gum

gum spin --title="guh-nome" && if exist gsettings; then
  gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
fi && echo "you got gnomed!"
