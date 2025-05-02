#!/bin/env fish

if exist pacman
	missing gum && pacman -S --noconfirm gum
	sudo gum spin --title="waka waka" -- sleep 5
end
