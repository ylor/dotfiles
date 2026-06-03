function linux-hide-app
    set application (gum choose (ls /usr/share/applications))
    printf "[Desktop Entry]\nHidden=true" >$DOTFILES/home/.local/share/applications/$application
    dfs-sync >/dev/null
end
