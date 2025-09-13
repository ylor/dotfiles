cd (status dirname)
source home/.config/fish/functions/dot.fish
dot-show-art

set -Ux DOT_PATH (realpath $PWD)
set -Ux DOT_HOME (realpath "home")
set -q DOT_MODE || dot-config

if [ $DOT_MODE = full ]
    set kernel (string lower (uname))
    for script in init/$kernel/*.fish
        set name $(basename $script .fish)
        dot-npc "configuring $name..."
        source $script
        dot-recho "configured $name!"
    end
end

dot-npc "linking dotfiles..."
dot-sync >/dev/null
dot-recho "linked dotfiles!"
dot-npc "✈ $(tput sitm)SEE YOU SPACE COWBOY…$(tput ritm)"
