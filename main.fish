#!/usr/bin/env fish
cd (status dirname)
source init/lib.fish
for script in init/$(kernel)/*.fish
    npc "Running: $(basename $script)"
    source $script
end
source init/link.fish
exec fish --login --interactive
