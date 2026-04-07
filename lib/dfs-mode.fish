function dfs-mode
    clear && dfs-show-art
    set -Ux DOTFILES_MODE (gum choose "Full" "Minimal" | string lower)
end
