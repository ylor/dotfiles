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
    systemctl is-enabled --quiet sshd; or sudo systemctl enable sshd; or return
    systemctl is-active --quiet sshd; or sudo systemctl start sshd; or return
end

# FIREWALL
# Distros like Omarchy enable ufw with their own rules, so check ours every run.
# ufw needs root even to read its status, so read its files instead.
if command -vq ufw
    set ssh 22/tcp
    set sunshine 47984/tcp 47989/tcp 47990/tcp 48010/tcp 47998/udp 47999/udp 48000/udp 48002/udp 48010/udp

    if not grep -qx 'DEFAULT_INPUT_POLICY="DROP"' /etc/default/ufw
        sudo ufw default deny incoming >/dev/null; or return
    end
    if not grep -qx 'DEFAULT_OUTPUT_POLICY="ACCEPT"' /etc/default/ufw
        sudo ufw default allow outgoing >/dev/null; or return
    end

    for rule in $ssh $sunshine
        set port_and_protocol (string split / $rule)
        set port $port_and_protocol[1]
        set protocol $port_and_protocol[2]
        grep -Fqx "### tuple ### allow $protocol $port 0.0.0.0/0 any 0.0.0.0/0 in" /etc/ufw/user.rules; and continue
        sudo ufw allow $rule >/dev/null; or return
    end

    if not systemctl is-enabled --quiet ufw
        sudo ufw --force enable >/dev/null; or return
        sudo systemctl enable ufw; or return
    end
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
        printf '%s\n' "$service_content" | sudo tee $service >/dev/null; or return
        sudo systemctl daemon-reload; or return
    end

    systemctl is-enabled --quiet gigabyte-suspend-workaround.service; or sudo systemctl enable gigabyte-suspend-workaround.service; or return
end

# GPU
command -q lact; or sudo pacman -S --needed --noconfirm lact; or return
systemctl is-enabled --quiet lactd; and systemctl is-active --quiet lactd; or sudo systemctl enable --now lactd; or return

dfs-success "Linux"
