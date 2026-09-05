# POWER MANAGEMENT
if upower --enumerate | grep -q BAT
    set power_profile balanced
else
    set power_profile performance
end

if test (powerprofilesctl get) != $power_profile
    powerprofilesctl set $power_profile
end

# ONBOARD
# fprintd fwupd

if command -vq sshd
    systemctl is-enabled --quiet sshd; or sudo systemctl enable sshd; or return $status
    systemctl is-active --quiet sshd; or sudo systemctl start sshd; or return $status
end

# FIREWALL
if command -vq ufw; and not systemctl is-enabled --quiet ufw
    # Allow nothing in, everything out
    sudo ufw default deny incoming; or return $status
    sudo ufw default allow outgoing; or return $status

    sudo ufw allow 22/tcp; or return $status # ssh
    sudo ufw allow 47990/tcp; or return $status # sunshine
    sudo ufw allow 47984/tcp; or return $status # sunshine
    sudo ufw allow 47989/tcp; or return $status # sunshine
    sudo ufw allow 48010/tcp; or return $status # sunshine
    sudo ufw allow 47998/udp; or return $status # sunshine
    sudo ufw allow 47999/udp; or return $status # sunshine
    sudo ufw allow 48000/udp; or return $status # sunshine
    sudo ufw allow 48002/udp; or return $status # sunshine
    sudo ufw allow 48010/udp; or return $status # sunshine

    sudo ufw enable; or return $status
    sudo ufw reload; or return $status
    sudo systemctl enable ufw; or return $status
end

# SECURE BOOT
# if command -vq sbctl
#     sudo sbctl create-keys
#     sudo sbctl enroll-keys --microsoft || exit 1
#     sudo sbctl status
#     sudo sbctl verify
#     #| sed 's/✗ /sbctl sign -s /e'
#     #sbctl status
# end

# GNOME
# if command -vq gsettings
#     gsettings set org.gnome.desktop.interface font-name 'Iosevka Aile 11'
#     gsettings set org.gnome.desktop.interface document-font-name 'Adwaita Sans 12'
#     gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'
#     gsettings set org.gnome.desktop.interface icon-theme breeze-dark
#     gsettings set org.gnome.desktop.wm.preferences button-layout :
# end

# DESKTOP
if grep -iq "B650 AORUS ELITE AX" /sys/devices/virtual/dmi/id/board_name
    set service /etc/systemd/system/gigabyte-suspend-workaround.service
    set service_content '[Unit]
    Description=Disable XH00 as ACPI wakeup source to workaround Gigabyte wake issues.
    After=multi-user.target

    [Service]
    Type=oneshot
    ExecStart=sh -c "echo XH00 > /proc/acpi/wakeup"

    [Install]
    WantedBy=multi-user.target'

    if not test -f $service; or test "$service_content" != (string collect <$service)
        printf '%s\n' "$service_content" | sudo tee $service >/dev/null; or return $status
        sudo systemctl daemon-reload; or return $status
    end

    systemctl is-enabled --quiet gigabyte-suspend-workaround.service; or sudo systemctl enable gigabyte-suspend-workaround.service; or return $status
end

if command -vq 1password
    set allowed_browsers /etc/1password/custom_allowed_browsers
    sudo mkdir -p /etc/1password
    sudo touch $allowed_browsers
    for browser in helium helium-browser
        sudo grep --fixed-strings --line-regexp --quiet $browser $allowed_browsers; or printf '%s\n' $browser | sudo tee --append $allowed_browsers >/dev/null; or return $status
    end
    sudo chmod 644 $allowed_browsers; or return $status
end

# TODO
## TODO: set firefox fonts, userjs, extensions
## VNC server/client

dfs-success "Linux configured."
