set -Ux DOTFILES (realpath (status dirname))
set -Ux DOTFILES_HOME "$DOTFILES/home"
# source $DOTFILES/lib/*.fish
set --prepend fish_function_path "$DOTFILES/lib"


test -z "$DOTFILES_MODE" && dfs-mode
clear && dfs-show-art
set kernel (uname | string lower)
test "$DOTFILES_MODE" = full && for s in $DOTFILES/lib/$kernel/**.fish
    source $s
end
dfs-spin --title="linking…" -- fish --interactive --command 'dfs-link'

# echo
# gum style --align center --border rounded --padding "0 1" --width 25 "✈ SEE YOU SPACE COWBOY… "
