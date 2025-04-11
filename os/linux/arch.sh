#!/bin/sh
if exist pacman; then
	! exist gum && pacman -S --noconfirm gum
	sudo gum spin --title="waka waka" -- pacman -S --noconfirm fish
fi
