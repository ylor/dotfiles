#!/bin/sh
set -eu

if exist gsettings; then
	gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
	gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'
fi && echo "you got gnomed!"
