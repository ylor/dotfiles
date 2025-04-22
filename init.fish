#!/usr/bin/env fish
cd (status dirname)
source lib.fish

spin sleep 5

switch (uname)
    case "Darwin"
        set ID "macos"
    case "Linux"
        source /etc/os-release
    case '*'
        error "OS not detected or supported."
end

if not test -d "os/$ID"
    error "'$ID' is not a supported operating system."
end

for sh in os/$ID/*.sh
    info $sh
    sh $sh && success || error
end

if exist gum
    gum spin --title="Linking dotfiles..." -- sh link.sh
else
    sh link.sh
end

if exist fish
    exec fish --login --interactive
end
