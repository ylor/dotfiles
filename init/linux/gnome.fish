#!/bin/env fish

if exist gsettings
	gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
	gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'
end
and echo "you got gnomed!"
