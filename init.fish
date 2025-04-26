#!/usr/bin/env fish
cd (status dirname)
source lib.fish

switch (uname)
    case Darwin
        set ID macos
    case Linux
        source /etc/os-release
    case '*'
        error "Supported OS not detected."
end

if test -d "os/$ID"
    for script in os/$ID/*.fish
        run "$script"
    end
    run link.fish
    exec fish --login --interactive
else
    error "'$ID' is not a supported operating system."
end
