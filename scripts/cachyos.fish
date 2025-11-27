paru -Syu

set pkgs (awk '{print $1}' "cachy/pkgs.txt")
paru -S --needed --skipreview $pkgs

# DESKTOP
if command -vq zeditor
    sudo cp /usr/share/icons/zed.png /usr/share/icons/hicolor/512x512/apps/zed.png
end

# AUTOLOGIN
# if lsblk -f | grep -iq crypto # only if the disk is encrypted
#     sudo mkdir -p "/etc/systemd/system/getty@tty1.service.d"
#     echo "[Service]
#     ExecStart=
#     ExecStart=-/usr/bin/agetty --autologin $(whoami) --noclear %I \$TERM" | sudo tee "/etc/systemd/system/getty@tty1.service.d/autologin.conf" >/dev/null
# end

# REMOVE UNWANTED INSTALLED BY DEFAULT
paru -Rs alacritty cachyos-micro-settings micro micro nano nano-syntax-highlighting pavucontrol polkit-kde-agent sddm
paru -c
