#!/bin/env fish
# dotfile "management"
set home (realpath "$(status dirname)/home")

function rehome
	string replace "$home" "$HOME" "$argv"
end

# find and stage folders for symlinks
find "$home" -type d | while read folder
	echo mkdir -pv "$(rehome "$folder")"
end

# find and symlink dotfiles
find "$home" -type f | while read file
    echo ln -sfv "$file" "$(rehome "$file")"
end

# purge broken symlinks
find -L "$HOME" -type l -maxdepth 1 -exec rm {} \+
find -L "$HOME/.config" "$HOME/.local" -type l -exec rm {} \+

# purge empty folders
find "$HOME" -type d -maxdepth 1 -empty -delete
find "$HOME/.config" "$HOME/.local" -type d -empty -delete
