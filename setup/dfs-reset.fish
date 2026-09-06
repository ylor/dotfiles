function dfs-reset --description "Clear the saved profile and configure the system"
    set --erase DOTFILES_PROFILE
    dfs-apply
end
