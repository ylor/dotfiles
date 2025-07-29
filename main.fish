#!/usr/bin/env fish
cd (status dirname)
source init/lib.fish

for script in init/$(kernel)/*.fish
    npc "running $(basename $script)..."
    source $script
end

npc "linking dotfiles..."
source init/link.fish
exec fish --login --interactive
