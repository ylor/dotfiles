set pkgs_dir (status dirname)/pkgs
set installed_pkgs (pacman -Qq)
set remove_pkgs
set cachy_pkgs
set aur_pkgs

for pkg in (awk 'NF && $1 !~ /^#/ {print $1}' $pkgs_dir/remove.txt)
    if contains -- $pkg $installed_pkgs
        set -a remove_pkgs $pkg
    end
end

if set -q remove_pkgs[1]
    sudo pacman -Rns --noconfirm $remove_pkgs
end

set installed_pkgs (pacman -Qq)

for pkg in (awk 'NF && $1 !~ /^#/ {print $1}' $pkgs_dir/cachy.txt)
    if not contains -- $pkg $installed_pkgs
        set -a cachy_pkgs $pkg
    end
end

for pkg in (awk 'NF && $1 !~ /^#/ {print $1}' $pkgs_dir/aur.txt)
    if not contains -- $pkg $installed_pkgs
        set -a aur_pkgs $pkg
    end
end

shelly sync standard --no-confirm
if set -q cachy_pkgs[1]
    shelly install standard --no-confirm $cachy_pkgs
end
if set -q aur_pkgs[1]
    shelly install aur --no-confirm $aur_pkgs
end
shelly purify standard --cache 3 --no-confirm

# DESKTOP
# if command -vq nvidia-smi
#     paru -S --needed --skipreview vk-hdr-layer-kwin6-git
# end

# AUTOLOGIN
if command -vq hyprland niri
    sudo mkdir -p "/etc/systemd/system/getty@tty1.service.d"
    echo "[Service]
     ExecStart=
     ExecStart=-/usr/bin/agetty --autologin $(whoami) --noclear %I \$TERM" | sudo tee "/etc/systemd/system/getty@tty1.service.d/autologin.conf" >/dev/null
end

# if command -vq hyprland niri
#     paru -S --needed --skipreview noctalia-shell ddcutil ddcci-driver-linux-dkms cliphist matugen cava wlsunset
# end

# if pidof -q hyprland && command -vq qs
#     qs -c noctalia-shell ipc call darkMode setLight
#     qs -c noctalia-shell ipc call darkMode setDark
# end

if command -vq lact
    if lspci | string match -q '*GeForce RTX 5070 Ti*'
        sudo install -Dm644 (status dirname)/lact.yaml /etc/lact/config.yaml
    end
    sudo systemctl enable --now lactd
end
