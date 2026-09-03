# POWER MANAGEMENT
if upower --enumerate | grep -q BAT
    set power_profile balance
else
    set power_profile performance
end

if test (powerprofilesctl get) != $power_profile
    powerprofilesctl set $power_profile
end

# ONBOARD
# fprintd fwupd

if command -vq ssh
    systemctl is-enabled --quiet sshd; or sudo systemctl enable sshd
    systemctl is-active --quiet sshd; or sudo systemctl start sshd
end

# FIREWALL
if command -vq ufw; and not systemctl is-enabled --quiet ufw
    # Allow nothing in, everything out
    sudo ufw default deny incoming
    sudo ufw default allow outgoing

    sudo ufw allow 22/tcp # ssh
    sudo ufw allow 47990/tcp # sunshine
    sudo ufw allow 47984/tcp # sunshine
    sudo ufw allow 47989/tcp # sunshine
    sudo ufw allow 48010/tcp # sunshine
    sudo ufw allow 47998/udp # sunshine
    sudo ufw allow 47999/udp # sunshine
    sudo ufw allow 48000/udp # sunshine
    sudo ufw allow 48002/udp # sunshine
    sudo ufw allow 48010/udp # sunshine

    sudo ufw enable
    sudo ufw reload
    sudo systemctl enable ufw
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
        printf '%s\n' "$service_content" | sudo tee $service >/dev/null
        sudo systemctl daemon-reload
    end

    systemctl is-enabled --quiet gigabyte-suspend-workaround.service; or sudo systemctl enable gigabyte-suspend-workaround.service
end

if command -vq 1password
    if not test -d /etc/1password
        sudo mkdir -p /etc/1password
    end

    set browser_file /etc/1password/custom_allowed_browsers
    if not test -f $browser_file; or test (cat $browser_file) != helium
        echo helium | sudo tee $browser_file >/dev/null
    end
end

# TODO
## TODO: set firefox fonts, userjs, extensions
## VNC server/client

dfs-success "Linux / configured"
