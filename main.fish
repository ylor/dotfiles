cd (status dirname)
source home/.config/fish/conf.d/lib.fish
source home/.config/fish/functions/dot.fish
set kernel (string lower (uname))

art
for script in init/$kernel/*.fish
    set name $(basename $script .fish)
    npc "configuring $name..."
    source $script
    recho "configured $name!"
end

npc "linking dotfiles..."
set --query devenv || set --universal devenv (realpath "home")
dot --sync >/dev/null
recho "linked dotfiles!"
npc "$(tput sitm)see you space cowboy$(tput ritm)"
