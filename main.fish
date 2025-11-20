set -Ux DOTFILES (realpath (status dirname))
set -Ux DOTFILES_HOME "$DOTFILES/home"

fish_add_path "$DOTFILES/bin" "$DOTFILES/home/.local/bin"

dfs-show-art
test -n "$DOTFILES_MODE" || dfs-mode

set kernel (uname | string lower)
source "scripts/$kernel.fish" 
# dfs-npc "linking dotfiles..."
# dfs-sync >/dev/null
# dfs-reverb "linked dotfiles!"
dfs-spin --title "linking..." dfs-sync
dfs-success "dotfiles linked!"

dfs-npc "✈ $(set_color --italic)SEE YOU SPACE COWBOY…"
