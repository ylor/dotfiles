set -Ux DOTFILES_PATH (realpath (status dirname))
# set -Ux DOT_PATH (realpath $PWD)
# set -Ux DOT_HOME (realpath "home")
fish_add_path $DOTFILES/bin
set -q DOTFILES_MODE || dot-config

# for cmd in $DOT_PATH/lib/*.fish
#     source $cmd
# end

dot-show-art
if [ $DOTFILES_MODE = full ]
    set kernel (uname | string lower)
    for script in lib/$kernel/*.fish
        set name $(basename $script .fish)
        dot-npc "configuring $name..."
        source $script
        dot-reverb "configured $name!"
    end
end

dot-npc "linking dotfiles..."
dot-sync >/dev/null
dot-reverb "linked dotfiles!"
dot-npc "✈ $(tput sitm)SEE YOU SPACE COWBOY…$(tput ritm)"
