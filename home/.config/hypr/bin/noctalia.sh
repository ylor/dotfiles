#!/usr/bin/env sh
inotifywait --event close_write --timeout 1 "$HOME/.config/noctalia/colors.json"

NOCTALIA_WALLPAPER=$(qs -c noctalia-shell ipc call state all | jq -r '.state.wallpapers | first(.[])')
ln -sf "$NOCTALIA_WALLPAPER" "$HOME/.config/noctalia/wallpaper"

eval "$(jq -r 'to_entries[] | "export " + (.key | sub("^m"; "NOCTALIA_") | ascii_upcase) + "=" + ("rgb(" + .value[1:] + ")" | @sh)' "$HOME/.config/noctalia/colors.json")"

echo "# automatically generated
accent = $NOCTALIA_PRIMARY
accent_secondary = $NOCTALIA_SECONDARY

font_family = Iosevka Aile
font_family_monospace = JetBrainsMono Nerd Font
" > $HOME/.config/hypr/hyprtoolkit.conf