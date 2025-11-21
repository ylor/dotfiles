sudo pacman -Syu

if not command -vq paru
    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
    pushd /tmp/paru-bin
    makepkg -si --needed --noconfirm
    popd
    rm -rf /tmp/paru-bin
end

# THIS DOESN'T WORK FIND OUT WHY AND FIX IT
set pkgs (cat "$DOTFILES/scripts/arch/pkgs.txt" | string join ' ')
sudo paru -S --needed --noconfirm $pkgs

# DESKTOP
systemctl --user enable xwayland-satellite