#!/usr/bin/envh sh
# hyprctl dispatch focusmonitor DP-1
# hyprctl dispatch workspace 1
# # hyprctl reload
# # hyprctl keyword monitor sunshine,disabled

# kill -SIGKILL $STREAMING_PID; STREAMING_PID=
hyprctl reload
hyprctl output remove sunshine