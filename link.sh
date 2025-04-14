#!/bin/sh
# dotfile "management"
set -eu

home="$(dirname $(realpath "$0"))/home"

rehome() {
	echo "$1" | sed "s_${home}_${HOME}_g"
}

# find and stage folders for symlinks
find "$home" -type d | while read folder; do
	mkdir -pv "$(rehome "$folder")"
done

# find and symlink dotfiles
find "$home" -type f | while read file; do
	ln -sfn "$file" "$(rehome "$file")"
done

# purge broken symlinks
find -L "$HOME" -type l -maxdepth 1 -exec rm {} \+
find -L "$HOME/.config" "$HOME/.local" -type l -exec rm {} \+

# purge empty folders
find "$HOME" -type d -maxdepth 1 -empty -delete
find "$HOME/.config" "$HOME/.local" -type d -empty -delete


# rm broken symlinks
# find "$HOME" "$HOME/.config" "$HOME/.local" -type d -maxdepth 1 -empty
# find -L "$HOME" -path "$HOME"/Library -prune -or -type l -exec rm {} \+ 2>/dev/null || true
# delete empty folders
# find "$HOME" -name "Library" -prune -or -mindepth 1 -type d -empty -delete 2>/dev/null || true
