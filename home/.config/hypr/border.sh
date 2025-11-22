#!/usr/bin/env sh
COLOR_PRIMARY=$(cat "$HOME/.config/noctalia/colors.json" | jq -r '.mPrimary' | cut -c2- | sed 's/$/ee/')
COLOR_SECONDARY=$(cat "$HOME/.config/noctalia/colors.json" | jq -r '.mOnPrimary' | cut -c2- | sed 's/$/ee/' )
hyprctl keyword general:col.active_border 0xff$COLOR_PRIMARY 0xff$COLOR_SECONDARY 45deg