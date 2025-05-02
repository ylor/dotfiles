#!/usr/bin/env fish
cd (status dirname)
source lib.fish
source link.fish

test -d init/$(kernel) || error "Supported OS not detected."
for file in init/$(kernel)/*.fish
    source $file
end
exec fish --login --interactive
