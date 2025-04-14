#!/bin/sh -e
# dotfile "management"

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
	ln -sfnv "$file" "$(rehome "$file")"
done

# delete empty folders
find "$HOME" -name "Library" -prune -or -mindepth 1 -type d -empty -delete 2>/dev/null || true
# rm broken symlinks
find -L "$HOME" -path "$HOME"/Library -prune -or -type l -exec rm {} \+ 2>/dev/null || true
# find -L "$HOME/.config" "$HOME/.local" -type l -exec rm {} \+
