paru -Syu

set pkgs (awk '{print $1}' "cachy/pkgs.txt")
paru -S --needed --skipreview $pkgs
paru --clean

# DESKTOP
if command -vq zeditor
    sudo cp /usr/share/icons/zed.png /usr/share/icons/hicolor/512x512/apps/zed.png
end

if command -vq nvidia-smi
    paru -S --needed --skipreview vk-hdr-layer-kwin6-git
end

# AUTOLOGIN
if command -vq hyprland niri
    sudo mkdir -p "/etc/systemd/system/getty@tty1.service.d"
    echo "[Service]
     ExecStart=
     ExecStart=-/usr/bin/agetty --autologin $(whoami) --noclear %I \$TERM" | sudo tee "/etc/systemd/system/getty@tty1.service.d/autologin.conf" >/dev/null
end

if command -vq hyprland niri
    paru -S --needed --skipreview noctalia-shell ddcutil ddcci-driver-linux-dkms cliphist matugen cava wlsunset
end

if pidof -q hyprland && command -vq qs
    qs -c noctalia-shell ipc call darkMode setLight
    qs -c noctalia-shell ipc call darkMode setDark
end

if command -vq lact
    paru -S --needed --skipreview lact
    sudo systemctl enable --now lactd
end
