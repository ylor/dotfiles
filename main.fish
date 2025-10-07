set -Ux DOT_PATH (realpath $PWD)
set -Ux DOT_HOME (realpath "home")
set -q DOT_MODE || dot-config

fish_add_path bin
# for cmd in $DOT_PATH/lib/*.fish
#     source $cmd
# end

dot-show-art
if [ $DOT_MODE = full ]
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
