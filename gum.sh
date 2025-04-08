#!/bin/sh -e
source lib.sh

exists git && echo yes || echo no

pkgs="bat mise zoxide fd fzf tldr yazi"
casks="1password appcleaner betterdisplay ghostty hyperkey linearmouse maccy alt-tab utm visual-studio-code helix zed jordanbaird-ice"
gum_pkgs=$(gum choose --header packages --no-limit $pkgs)
gum_casks=$(gum choose --header casks --no-limit $casks)

brew install $gum_pkgs

# for i in $(seq 1 5); do
#     gum spin --spinner $(spinner) --title "we spin" -- sleep 1
# done

#brew install bat mise zoxide # fd fzf tldr yazi
#brew install --cask --force 1password appcleaner betterdisplay ghostty hyperkey linearmouse maccy #alt-tab utm visual-studio-code helix zed jordanbaird-ice
