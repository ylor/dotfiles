#!/usr/bin/env sh
# notify-send foo
inotifywait --event close_write --timeout 1 "$HOME/.config/noctalia/colors.json"

# NOCTALIA_WALLPAPER=$(qs -c noctalia-shell ipc call state all | jq -r '.state.wallpapers | first(.[])')
# ln -sf "$NOCTALIA_WALLPAPER" "$HOME/.config/noctalia/wallpaper"

# jq -r 'to_entries[] | "export " + (.key | sub("^m"; "NOCTALIA_") | ascii_upcase) + "=\"" + .value + "\""' "$HOME/.config/noctalia/colors.json"

# NOCTALIA_COLOR_PRIMARY=$(cat "$HOME/.config/noctalia/colors.json" | jq -r '.mPrimary' | cut -c2- | sed -e 's/^/0xee/')
# NOCATALIA_COLOR_SECONDARY=$(cat "$HOME/.config/noctalia/colors.json" | jq -r '.mHover' | cut -c2- | sed -e 's/^/0xee/')
# hyprctl keyword general:col.active_border $NOCTALIA_COLOR_PRIMARY $NOCATALIA_COLOR_SECONDARY 45deg
# # pidof hyprlock && pkill -USR2 hyprlock
# # notify-send "Wallpaper changed"

export foo=bar
notify-send $foo