set -Ux DOTFILES (realpath (status dirname))
set -Ux DOTFILES_HOME "$DOTFILES/home"
fish_add_path "$DOTFILES/bin" #"$DOTFILES/home/.local/bin"

clear
test -z "$DOTFILES_MODE" && dfs-mode || dfs-show-art
set kernel (uname | string lower)
[ "$DOTFILES_MODE" = full ] && source scripts/$kernel.fish
dfs-spin --title "linking..." dfs-sync
dfs-success "dotfiles linked!"
dfs-npc "✈ $(set_color --italic)SEE YOU SPACE COWBOY…"
