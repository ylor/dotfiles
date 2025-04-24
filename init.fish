#!/usr/bin/env fish
cd (status dirname)
source lib.fish

switch (uname)
    case "Darwin"
        set ID "macos"
    case "Linux"
        source "/etc/os-release"
    case '*'
        error "OS not detected or supported."
end

if not test -d "os/$ID"
    error "'$ID' is not a supported operating system."
end

for sh in os/$ID/*.sh
    info $sh && sh $sh && success $sh || error $sh
end

if info "Linking dotfiles..." && fish link.fish >/dev/null
    success "Linked!"
else
    error "Linking"
end

if command --search --quiet fish
    exec fish --login --interactive
end
