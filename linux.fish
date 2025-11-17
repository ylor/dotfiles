sudo true
# PACKAGES
# sudo pacman -Syu

# AUR 
if not command -vq paru
    paru -S --needed base-devel
    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
    pushd /tmp/paru-bin
    makepkg -si --noconfirm
    popd
    rm -rf /tmp/paru-bin
end

# POWER MANAGEMENT
paru -S --noconfirm --needed power-profiles-daemon zram-generator
if upower --enumerate | grep BAT
    powerprofilesctl set balance
else
    powerprofilesctl set performance
end

paru -S --needed --noconfirm brightnessctl ddcutil fprintd fwupd
paru -S --needed --noconfirm ddcci-driver-linux-dkms

# NETWORK
paru -S --needed --noconfirm bluez bluez-utils iwd networkmanager
sudo systemctl enable bluetooth.service

# FIREWALL
paru -S --needed --noconfirm ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable
sudo ufw reload
sudo systemctl enable ufw

# AUDIO
paru -S --needed --noconfirm pipewire pipewire-alsa pipewire-jack pipewire-pulse libpulse wireplumber

# SECURE BOOT
# paru -S --needed --noconfirm sbctl

# TERMINAL
paru -S --needed --noconfirm fish fd git gum
paru -S --needed --noconfirm btop bat eza evil-helix-bin podman podman-compose viu vim wget unzip zoxide

# DESKTOP
paru -S --needed --noconfirm
paru -S --needed --noconfirm uwsm hyprland hypridle hyprlock hyprshot
paru -S --needed --noconfirm polkit-gnome xwayland-satellite qt5-wayland qt6-wayland xdg-desktop-portal-gnome xdg-desktop-portal-gtk xdg-desktop-portal-hyprland
paru -S --needed --noconfirm waybar otf-font-awesome
paru -S --needed --noconfirm noctalia-shell cava mutagen-git gpu-screen-recorder
paru -S --needed --noconfirm ttf-iosevka-aile ttf-jetbrains-mono-nerd
paru -S --needed --noconfirm adw-gtk-theme gnome-themes-extra
paru -S --needed --noconfirm cliphist wl-clipboard wlsunset
systemctl --user enable xwayland-satellite

# APPLICATIONS
paru -S --needed --noconfirm 1password-beta firefox ghostty nautilus zed
paru -S --needed --noconfirm gvfs-mtp gvfs-nfs gvfs-smb