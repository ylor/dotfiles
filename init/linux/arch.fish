#!/bin/env fish

if exist pacman
	missing gum && sudo pacman -S --noconfirm gum
	sudo gum spin --title="waka waka" -- sleep 5
end
