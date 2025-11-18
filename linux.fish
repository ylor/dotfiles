sudo pacman -Syu
sudo pacman -S --needed --noconfirm linux linux-headers linux-firmware base base-devel

if not command -vq paru
    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
    pushd /tmp/paru-bin
    makepkg -si --needed --noconfirm
    popd
    rm -rf /tmp/paru-bin
end

alias install='paru -S --needed --noconfirm --sudoloop'
# POWER MANAGEMENT
paru -S --noconfirm --needed power-profiles-daemon zram-generator
if upower --enumerate | grep BAT
    powerprofilesctl set balance
else
    powerprofilesctl set performance
end

# 
install brightnessctl ddcutil ddcci-driver-linux-dkms fprintd fwupd

# NETWORK
install bluez bluez-utils iwd networkmanager
sudo systemctl enable bluetooth.service

# FIREWALL
install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable
sudo ufw reload
sudo systemctl enable ufw

# AUDIO
install pipewire pipewire-alsa pipewire-jack pipewire-pulse libpulse wireplumber

# SECURE BOOT
# install sbctl

# TERMINAL
install fish fd git gum
install man unzip
install mise usage
install btop bat eza evil-helix-bin podman podman-compose ripgrep viu vim wget unzip zoxide

# DESKTOP
paru -S --needed --noconfirm
install uwsm hyprland hypridle hyprlock hyprshot
install hyprcursor hyprpicker
install gpu-screen-recorder polkit-gnome xwayland-satellite qt5-wayland qt6-wayland xdg-desktop-portal-gnome xdg-desktop-portal-gtk xdg-desktop-portal-hyprland xdg-terminal-exec xdg-user-dirs
install waybar otf-font-awesome
install noctalia-shell cava matugen-bin
install ttf-iosevka-aile ttf-jetbrains-mono-nerd
install adw-gtk-theme gnome-themes-extra
install cliphist tzupdate wl-clipboard wlsunset
systemctl --user enable xwayland-satellite

# APPLICATIONS
install firefox ghostty nautilus
install gvfs-mtp gvfs-nfs gvfs-smb
install 1password-beta firefox gnome-calculator gnome-disk-utility zed
