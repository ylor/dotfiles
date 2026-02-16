#!/usr/bin/env sh

# hyprctl output create headless sunshine
hyprctl keyword monitor sunshine,"${SUNSHINE_CLIENT_WIDTH-3840}"x"${SUNSHINE_CLIENT_HEIGHT-2160}"@"${SUNSHINE_CLIENT_FPS-60}",4000x0,1
# for m in $(hyprctl monitors -j | jq -r '.[] | .name' | grep -v sunshine); do
#        hyprctl keyword monitor "$m,disabled"
# done
hyprctl dispatch workspace 9
hyprctl dispatch focusmonitor sunshine
# hyprctl keyword monitor DP-1,disabled
# hyprctl output remove sunshine
#systemd-inhibit --what=idle
systemd-inhibit --no-ask-password --what=idle --who="me" --why="streaming" sh & disown; export STREAMING_PID=$!
