if command -vq pacman
    sudo pacman -Syu --noconfirm
    
    set pkgs base-devel ghostty mise wl-clipboard usage zed zoxide 
    sudo pacman -S --noconfirm --needed $pkgs
end

if command -vq paru
    set pkgs_aur 1password evil-helix-bin ludusavi-bin helium-browser-bin faugus-launcher sunshine-beta-bin vk-hdr-layer-kwin6-git
    paru -S --noconfirm --needed $pkgs_aur
end
