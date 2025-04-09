#!/bin/sh
# https://github.com/typecraft-dev/crucible

if exist gsettings; then
  gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
fi
