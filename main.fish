set -Ux DOTFILES (realpath (status dirname))
fish_add_path "$DOTFILES/bin"
dfs-show-art

set -q DOTFILES_MODE || dfs-mode

if [ $DOTFILES_MODE = full ]
    set kernel (uname | string lower)
    for script in $DOTFILES/lib/$kernel/*.fish
        set name $(basename $script .fish)
        dfs-npc "configuring $name..."
        source $script
        dfs-reverb "configured $name!"
    end
end

# dfs-config
dfs-npc "linking dotfiles..."
dfs-sync >/dev/null
dfs-reverb "linked dotfiles!"

dfs-npc "✈ $(set_color --italic)SEE YOU SPACE COWBOY…"
