set distro_dir (path resolve (status dirname))
set pkgs_dir $distro_dir/packages
set installed_pkgs (pacman -Qq)
set remove_pkgs
set cachy_pkgs
set aur_pkgs

set requested_removals (awk 'NF && $1 !~ /^#/ {print $1}' $pkgs_dir/remove.txt)
for pkg in $requested_removals
    if contains -- $pkg $installed_pkgs
        set -a remove_pkgs $pkg
    end
end

if set -q remove_pkgs[1]
    sudo pacman -Rns --noconfirm $remove_pkgs
end

set installed_pkgs (pacman -Qq)

set requested_cachy (awk 'NF && $1 !~ /^#/ {print $1}' $pkgs_dir/cachy.txt)
for pkg in $requested_cachy
    if not contains -- $pkg $installed_pkgs
        set -a cachy_pkgs $pkg
    end
end

set requested_aur (awk 'NF && $1 !~ /^#/ {print $1}' $pkgs_dir/aur.txt)
for pkg in $requested_aur
    if not contains -- $pkg $installed_pkgs
        set -a aur_pkgs $pkg
    end
end

if set -q cachy_pkgs[1]
    shelly install standard --no-confirm $cachy_pkgs
end
if set -q aur_pkgs[1]
    shelly install aur --no-confirm $aur_pkgs
end

# DESKTOP
# if command -vq nvidia-smi
#     paru -S --needed --skipreview vk-hdr-layer-kwin6-git
# end

# AUTOLOGIN
if command -vq hyprland niri
    set autologin /etc/systemd/system/getty@tty1.service.d/autologin.conf
    set autologin_content "[Service]
     ExecStart=
     ExecStart=-/usr/bin/agetty --autologin $(whoami) --noclear %I \$TERM"

    if not test -f $autologin; or test "$autologin_content" != (string collect <$autologin)
        printf '%s\n' "$autologin_content" | sudo install -Dm644 /dev/stdin $autologin
    end
end

# if command -vq hyprland niri
#     paru -S --needed --skipreview noctalia-shell ddcutil ddcci-driver-linux-dkms cliphist matugen cava wlsunset
# end

# if pidof -q hyprland && command -vq qs
#     qs -c noctalia-shell ipc call darkMode setLight
#     qs -c noctalia-shell ipc call darkMode setDark
# end

if command -vq lact
    set lact_source $distro_dir/files/lact.yaml
    set lact_config /etc/lact/config.yaml

    if lspci | string match -q '*GeForce RTX 5070 Ti*'; and not cmp --silent $lact_source $lact_config
        sudo install -Dm644 $lact_source $lact_config
    end

    systemctl is-enabled --quiet lactd; or sudo systemctl enable lactd
    systemctl is-active --quiet lactd; or sudo systemctl start lactd
end

dfs-success "CachyOS configured."
