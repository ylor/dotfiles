command -q 1password || omarchy install service 1password
command -q ghostty || omarchy default terminal --install ghostty

omarchy pkg drop foot && rm -f ~/.local/share/applications/foot.desktop
omarchy pkg drop obsidian
omarchy pkg drop kdenlive
omarchy pkg drop libreoffice-fresh
omarchy pkg drop obs-studio
omarchy pkg drop pinta
omarchy pkg drop system-config-printer
omarchy pkg drop xournalpp

omarchy webapp remove all >/dev/null

