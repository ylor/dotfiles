# SETUP
set distro (cat /etc/os-release | grep '^ID=' | cut -d= -f2)

source scripts/$distro/$distro.fish

# POWER MANAGEMENT
if upower --enumerate | grep BAT
    powerprofilesctl set balance
else
    powerprofilesctl set performance
end

# ONBOARD
# fprintd fwupd

# NETWORK
sudo systemctl enable bluetooth.service

# FIREWALL

# AUDIO
# install pipewire pipewire-{alsa,jack,pulse} libpulse wireplumber

# SECURE BOOT
# sbctl


# DESKTOP
systemctl --user enable xwayland-satellite
