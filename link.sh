#!/bin/sh

# Clean up broken symlinks
find -L "$HOME/.config" -type l -exec rm {} \;
find -L "$HOME/.local" -type l -exec rm {} \;

rehome() {
	echo "$1" | sed "s_${PWD}_${HOME}_g"
}

# Find all necesssary folders that symlinks need
find "${PWD}" \
	-type d \
	-mindepth 2 \
	-not -path "*.git*" | while read folder; do
    	mkdir -pv "$(rehome "${folder}")"
    done

# Find all files that will be symlinked
find "${PWD}" \
	-type f \
	-mindepth 2 \
	-not -path "*.git*" | while read file; do
    	ln -sfnv "$file" "$(rehome "${file}")"
    done
