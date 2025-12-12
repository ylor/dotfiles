# SETUP
set distro (cat /etc/os-release | grep '^ID=' | cut -d= -f2)

# source scripts/$distro.fish

# POWER MANAGEMENT
if upower --enumerate | grep BAT
    powerprofilesctl set balance
else
    powerprofilesctl set performance
end

# ONBOARD
# fprintd fwupd

# NETWORK
for eth in (nmcli --terse connection show --active | grep ethernet | cut -d ":" -f2)
    nmcli connection modify "$eth" 802-3-ethernet.wake-on-lan magic
end
# sudo systemctl enable bluetooth.service

# FIREWALL

# SECURE BOOT
# sbctl

# GNOME
if command -vq gsettings
    gsettings set org.gnome.desktop.interface font-name 'Iosevka Aile 11'
    gsettings set org.gnome.desktop.interface document-font-name 'Adwaita Sans 12'
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'
    gsettings set org.gnome.desktop.interface icon-theme 'breeze-dark'
    gsettings set org.gnome.desktop.wm.preferences button-layout :
end

# DESKTOP
# TODO: set firefox fonts, userjs, extensions

# FIX GIGABYTE SLEEP
if cat /sys/devices/virtual/dmi/id/board_name | grep -iq "B650 AORUS ELITE AX" #&& not grep -q acpi_osi /etc/default/limine
#     echo 'KERNEL_CMDLINE[default]+="acpi_osi=\"!Windows 2015\""' | sudo tee -a /etc/default/limine &>/dev/null
echo '[Unit]
Description=Disable XH00 as ACPI wakeup source to workaround Gigabyte sleep issue
After=multi-user.target

[Service]
Type=oneshot
ExecStart=sh -c "echo XH00 > /proc/acpi/wakeup"

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/gigabyte-suspend-workaround.service
sudo systemctl daemon-reload
sudo systemctl enable gigabyte-suspend-workaround.service
sudo systemctl start gigabyte-suspend-workaround.service
end
