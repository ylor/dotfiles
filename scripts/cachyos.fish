paru -Syu

set pkgs (awk '{print $1}' "cachy/pkgs.txt")
#paru -Rs alacritty cachyos-micro-settings kitty micro nano nano-syntax-highlighting pavucontrol hyprpolkitagent uwsm ttf-opensans 
paru -S --needed --skipreview $pkgs
paru --clean

#paru -Rs --noconfirm cachyos-zsh-config cachyos-fish-config ttf-bitstream-vera ttf-dejavu ttf-liberation ttf-meslo-nerd vlc-plugins-all noto-color-emoji-fontconfig noto-fonts noto-fonts-cjk noto-fonts-emoji nano nano-syntax-highlighting pv glances awesome-terminal-fonts

# DESKTOP
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

if command -vq qs
    qs -c noctalia-shell ipc call darkMode setLight
    # sleep 0.5 to trigger color gen with no wallpapers available
    qs -c noctalia-shell ipc call darkMode setDark
end