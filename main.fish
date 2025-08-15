cd (status dirname)
source home/.config/fish/conf.d/lib.fish
source home/.config/fish/functions/dot.fish
set kernel (string lower (uname))

art

set signal "$HOME/.local/state/devenv/install"
test -e $signal || mode

set state (cat $signal)
if [ $state = full ]
    for script in init/$kernel/*.fish
        set name $(basename $script .fish)
        npc "configuring $name..."
        source $script
        recho "configured $name!"
    end
end

npc "linking dotfiles..."
set --query devenv || set --universal devenv (realpath "home")
dot --sync >/dev/null
recho "linked dotfiles!"
echo
npc "✈ $(tput sitm)SEE YOU SPACE COWBOY…$(tput ritm)"
