#!/bin/env fish
# dotfile "management"
set env (realpath "$(status dirname)/home")

sh test.sh

function rehome
    string replace "$env" "$HOME" "$argv"
end

# stage folders
find "$env" -type d | while read folder
    mkdir -p "$(rehome "$folder")"
end

# symlink dotfiles
find "$env" -type f | while read file
    ln -sf "$file" "$(rehome "$file")"
end

# purge broken symlinks
find -L "$HOME" -type l -maxdepth 1 -exec rm {} \+
find -L "$HOME/.config" "$HOME/.local" -type l -exec rm {} \+

# purge empty folders
find "$HOME" -type d -maxdepth 1 -empty -delete
find "$HOME/.config" "$HOME/.local" -type d -empty -delete
