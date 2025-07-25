#!/usr/bin/env fish
cd (status dirname)
source lib.fish
test -d init/$(kernel) || error "Supported OS not detected."
for file in init/$(kernel)/*.fish
    echo source $file
end
echo source link.fish
echo exec fish --login --interactive
