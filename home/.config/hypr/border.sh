#!/usr/bin/env sh
sleep 1
COLOR_PRIMARY=$(cat "$HOME/.config/noctalia/colors.json" | jq -r '.mPrimary' | cut -c2- | sed -e 's/^/0xee/')
COLOR_SECONDARY=$(cat "$HOME/.config/noctalia/colors.json" | jq -r '.mTertiary' | cut -c2- | sed -e 's/^/0xee/')
hyprctl keyword general:col.active_border $COLOR_PRIMARY $COLOR_SECONDARY 45deg
# notify-send "foo"