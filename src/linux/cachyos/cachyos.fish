shelly sync

set pkgs (awk '{print $1}' "pkgs.txt")
shelly install --no-confirm $pkgs 
shelly cache-clean

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
    sudo systemctl enable --now lactd
end
