if exist pacman
    sudo pacman -Syu
    sudo pacman -S --noconfirm gum
    
    if exist gsettings
        echo GNOME
    else if exist hyprland
        echo hyprland
    else
        gum choose GNOME Hyprland
    end

    sudo pacman -S --noconfirm kitty hyprland
    sudo gum spin --title="waka waka" -- sleep 5
end
