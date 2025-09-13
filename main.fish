cd (status dirname)
source home/.config/fish/functions/struct.fish
set -Ux struct_path (realpath $PWD)
set -Ux struct_home (realpath "home")
set -q struct_mode || struct-mode

struct-art
if [ $struct_mode = full ]
    set kernel (string lower (uname))
    for script in init/$kernel/*.fish
        set name $(basename $script .fish)
        npc "configuring $name..."
        source $script
        recho "configured $name!"
    end
end

npc "linking dotfiles..."
struct --sync >/dev/null
recho "linked dotfiles!"
echo
npc "✈ $(tput sitm)SEE YOU SPACE COWBOY…$(tput ritm)"
