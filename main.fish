#!/usr/bin/env fish
cd (status dirname)
source lib.fish
test -d init/$(kernel) || error "Supported OS not detected."
for file in init/$(kernel)/*.fish
    echo source $file
end
source link.fish
exec fish --login --interactive
