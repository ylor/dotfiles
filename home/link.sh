#!/bin/sh -e
# dotfile "management"

wd=$(dirname $(realpath "$0"))

rehome() {
	echo "$1" | sed "s_${wd}_${HOME}_g"
}

# find and stage folders for symlinks
find "$wd" -type d | while read folder; do
	mkdir -p "$(rehome "${folder}")"
done

# find and symlink dotfiles
find "$wd" -type f -mindepth 2 | while read file; do
	ln -sfn "$file" "$(rehome "${file}")"
done

# delete empty folders
find "$HOME" -name "Library" -prune -or -type d -empty -delete 2>/dev/null || true
# rm broken symlinks
find -L "$HOME" -path "$HOME"/Library -prune -or -type l -exec rm {} \+ 2>/dev/null || true
# find -L "$HOME/.config" "$HOME/.local" -type l -exec rm {} \+
