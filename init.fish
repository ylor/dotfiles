#!/usr/bin/env fish
cd (status dirname)
source lib.fish
link

switch (uname)
    case Darwin
        set ID macos
    case Linux
        # source /etc/os-release
        # set OS (cat /etc/os-release | grep "^ID=" | cut -d "=" -f 2)
        set ID linux
    case '*'
        error "Supported OS not detected."
end

if test -d "os/$ID"
    for script in os/$ID/*.fish
        run "$script"
    end
    exec fish --login --interactive
else
    error "'$ID' is not a supported operating system."
end
