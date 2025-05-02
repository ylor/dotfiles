#!/usr/bin/env fish
cd (status dirname)
source lib.fish
source link.fish

switch (uname)
    case Darwin
        set os mac
    case Linux
        # set os (cat /etc/os-release | grep "^ID=" | cut -d "=" -f 2)
        set os linux
    case '*'
        error "Supported OS not detected."
end

for file in init/$os/*.fish
    source $file
end
# exec fish --login --interactive
