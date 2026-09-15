command -q 1password; or omarchy install service 1password
command -q ghostty; or omarchy default terminal --install ghostty
command -q hypridle; or omarchy pkg add hypridle
systemctl --user is-enabled --quiet hypridle; or systemctl --user enable hypridle
command -q flea; or omarchy pkg add flea
command -q trash; or omarchy pkg add trash-cli

command -q lact; or omarchy pkg add lact
systemctl is-enabled --quiet lactd; and systemctl is-active --quiet lactd; or sudo systemctl enable --now lactd

set installed_plugins (omarchy plugin list --json | jq -r '.[].id')
contains njpatel.omapager $installed_plugins; or omarchy plugin add https://github.com/njpatel/omapager.git --enable --yes
contains jankeesvw.notification-center $installed_plugins; or omarchy plugin add https://github.com/jankeesvw/omarchy-notification-center.git --enable --yes

omarchy pkg drop docker ufw-docker kdenlive libreoffice-fresh obs-studio obsidian pinta system-config-printer xournalpp

omarchy webapp remove all >/dev/null

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

dfs-success "Omarchy"
