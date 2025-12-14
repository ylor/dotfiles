# SETUP
set distro (cat /etc/os-release | grep '^ID=' | cut -d= -f2)

source scripts/$distro.fish

# POWER MANAGEMENT
if upower --enumerate | grep BAT
    powerprofilesctl set balance
else
    powerprofilesctl set performance
end

# ONBOARD
# fprintd fwupd

# FIREWALL
if command -vq ufw
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
if command -vq gsettings
    gsettings set org.gnome.desktop.interface font-name 'Iosevka Aile 11'
    gsettings set org.gnome.desktop.interface document-font-name 'Adwaita Sans 12'
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'
    gsettings set org.gnome.desktop.interface icon-theme 'breeze-dark'
    gsettings set org.gnome.desktop.wm.preferences button-layout :
end

# DESKTOP
# FIX GIGABYTE SLEEP
if cat /sys/devices/virtual/dmi/id/board_name | grep -iq "B650 AORUS ELITE AX" 
    echo '[Unit]
    Description=Disable XH00 as ACPI wakeup source to workaround Gigabyte sleep issue
    After=multi-user.target
    
    [Service]
    Type=oneshot
    ExecStart=sh -c "echo XH00 > /proc/acpi/wakeup"
    
    [Install]
    WantedBy=multi-user.target' | sudo tee /etc/systemd/system/gigabyte-suspend-workaround.service >/dev/null
    
    sudo systemctl daemon-reload
    sudo systemctl enable gigabyte-suspend-workaround.service
    sudo systemctl start gigabyte-suspend-workaround.service
end

if command -vq efibootmgr
    echo "$(whoami) ALL=(root) NOPASSWD: /usr/bin/efibootmgr -n *" | sudo tee "/etc/sudoers.d/efibootmgr"
end

# TODO
## TODO: set firefox fonts, userjs, extensions
## VNC server/client