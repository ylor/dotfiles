#!/bin/env sh
NOCTALIA_WALLPAPER=$(qs -c noctalia-shell ipc call state all | jq -r '.state.wallpapers | first(.[])')
ln -sf "$NOCTALIA_WALLPAPER" "$HOME/.config/noctalia/wallpaper"