function dot-config
    dot-show-art
    if gum confirm "Choose your style:" --affirmative="Full" --negative="Minimal" --no-show-help
        set -Ux DOTFILES_MODE full
    else
        set -Ux DOTFILES_MODE minimal
    end
end
