function dfs-mode
    dfs-show-art
    set res (gum choose "Full" "Minimal" | string lower)
    set -Ux DOTFILES_MODE $res
end
