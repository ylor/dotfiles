sudo pacman -Syu

if not command -vq paru
    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
    pushd /tmp/paru-bin
    makepkg -si --needed --noconfirm
    popd
    rm -rf /tmp/paru-bin
end

# THIS DOESN'T WORK FIND OUT WHY AND FIX IT
set pkgs (awk '{print $1}' pkgs.txt)
paru -S --needed --skipreview $pkgs

# DESKTOP
systemctl --user enable xwayland-satellite
if command -vq zeditor
    sudo cp /usr/share/icons/zed.png /usr/share/icons/hicolor/512x512/apps/zed.png
end

# AUTOLOGIN
if lsblk -f | grep -iq crypto # only if the disk is encrypted
    sudo mkdir -p "/etc/systemd/system/getty@tty1.service.d"
    echo "[Service]
    ExecStart=
    ExecStart=-/usr/bin/agetty --autologin $(whoami) --noclear %I \$TERM" | sudo tee "/etc/systemd/system/getty@tty1.service.d/autologin.conf" >/dev/null
end
