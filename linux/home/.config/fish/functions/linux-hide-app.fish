function linux-hide-app
    set application (gum choose (ls /usr/share/applications))
    printf "[Desktop Entry]\nHidden=true" >$DOTFILES/linux/home/.local/share/applications/$application
    dfs-link >/dev/null
end
