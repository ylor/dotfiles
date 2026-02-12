#!/usr/bin/envh sh

hyprctl output create sunshine
hyprctl keyword monitor sunshine,2560x1440@60,auto,1
sh -c "hyprctl keyword monitor sunshine,${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS},auto,1"
hyprctl output remove sunshine
