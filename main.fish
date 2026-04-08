set -Ux DOTFILES (realpath (status dirname))
set --prepend fish_function_path "$DOTFILES/src"

test -z $DOTFILES_MODE && dfs-mode
clear && dfs-show-art
set kernel (uname | string lower)
if test "$DOTFILES_MODE" = full
    for s in $DOTFILES/$kernel/scripts/*.fish
        source $s
    end
end

dfs-spin --title="linking…" -- fish --interactive --command "dfs-link --minimal"

# echo
# gum style --align center --border rounded --padding "0 1" --width 25 "✈ SEE YOU SPACE COWBOY… "
