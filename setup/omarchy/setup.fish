command -q 1password; or omarchy install service 1password
command -q ghostty; or omarchy default terminal --install ghostty
command -q hypridle; or omarchy pkg add hypridle
systemctl --user is-enabled --quiet hypridle; or systemctl --user enable hypridle
command -q flea; or omarchy pkg add flea
# paused: command -q strata; or omarchy pkg add strata
command -q trash; or omarchy pkg add trash-cli
make --silent -C ~/.config/hypr/plugins/expand; or return $status

omarchy pkg drop docker docker-buildx docker-compose lazydocker ufw-docker nautilus nautilus-python foot libreoffice-fresh obsidian pinta system-config-printer

omarchy webapp remove all >/dev/null
test -f ~/.local/share/applications/Docker.desktop; and omarchy tui remove Docker >/dev/null

set wake_rule /etc/udev/rules.d/90-nuphy-disable-wakeup.rules
set wake_rule_content 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="19f5", ATTR{idProduct}=="1028", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="3710", ATTR{idProduct}=="5406", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"'

if not test -f $wake_rule; or test "$wake_rule_content" != (string collect <$wake_rule)
    printf '%s\n' "$wake_rule_content" | sudo tee $wake_rule >/dev/null
    sudo chmod 644 $wake_rule
    sudo udevadm control --reload-rules
    sudo udevadm trigger --action=add --subsystem-match=usb --attr-match=idVendor=19f5 --attr-match=idProduct=1028
end

if test (omarchy font current) != "Berkeley Mono Variable"
    omarchy font set "Berkeley Mono Variable" >/dev/null 2>&1; or return $status
end

omarchy-hyprland-toggle no-animations on

dfs-success "Omarchy"
