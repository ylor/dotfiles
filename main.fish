cd (status dirname)
source home/.config/fish/functions/dot.fish
source home/.config/fish/functions/lib.fish

art
for script in init/$(kernel)/*.fish
    npc "running $(basename $script)..."
    source $script
end

npc "linking dotfiles..."
set --query devenv || set --universal devenv (realpath "home")
dot --sync >/dev/null

npc "open a new tab to begin computing"
