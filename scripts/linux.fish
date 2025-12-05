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
# if command -vq gsettings
#     gsettings set org.gnome.desktop.wm.preferences button-layout :
#     gsettings set org.gnome.desktop.interface font-name 'Iosevka Aile 11'
#     gsettings set org.gnome.desktop.interface icon-theme 'breeze'
#     gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'
# end

# DESKTOP
# TODO: set firefox fonts, userjs, extensions

