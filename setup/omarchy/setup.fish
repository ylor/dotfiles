command -q 1password; or omarchy install service 1password
command -q ghostty; or omarchy default terminal --install ghostty
command -q hypridle; or omarchy pkg add hypridle
systemctl --user is-enabled --quiet hypridle; or systemctl --user enable hypridle
command -q flea; or omarchy pkg add flea
command -q lact; or omarchy pkg add lact
command -q trash; or omarchy pkg add trash-cli
systemctl is-enabled --quiet lactd; or sudo systemctl enable lactd
systemctl is-active --quiet lactd; or sudo systemctl start lactd

# omarchy pkg drop foot && rm -f ~/.local/share/applications/foot.desktop
omarchy pkg drop docker ufw-docker
omarchy pkg drop kdenlive
omarchy pkg drop libreoffice-fresh
omarchy pkg drop obs-studio
omarchy pkg drop obsidian
omarchy pkg drop pinta
omarchy pkg drop system-config-printer
omarchy pkg drop xournalpp

omarchy webapp remove all >/dev/null

set wake_rule /etc/udev/rules.d/90-nuphy-disable-wakeup.rules
set wake_rule_content 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="19f5", ATTR{idProduct}=="1028", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"'

if not test -f $wake_rule; or test "$wake_rule_content" != (string collect <$wake_rule)
    printf '%s\n' "$wake_rule_content" | sudo tee $wake_rule >/dev/null
    sudo chmod 644 $wake_rule
    sudo udevadm control --reload-rules
    sudo udevadm trigger --action=add --subsystem-match=usb --attr-match=idVendor=19f5 --attr-match=idProduct=1028
end

dfs-success "Omarchy configured."
