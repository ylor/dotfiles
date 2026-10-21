# POWER MANAGEMENT
if upower --enumerate | grep -q BAT
    set power_profile balanced
else
    set power_profile performance
end

if test (powerprofilesctl get) != $power_profile
    powerprofilesctl set $power_profile
end

if command -vq sshd
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

# GPU
command -q lact; or sudo pacman -S --needed --noconfirm lact
systemctl is-enabled --quiet lactd; and systemctl is-active --quiet lactd; or sudo systemctl enable --now lactd

dfs-success "Linux"
