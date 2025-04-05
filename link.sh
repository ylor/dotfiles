#!/bin/sh

# Clean up broken symlinks
find -L "$HOME/.config" -type l -exec rm {} \;
find -L "$HOME/.local" -type l -exec rm {} \;

# Find all necesssary folders that symlinks succeed
     find "${PWD}" \
    -type d \
    -mindepth 2 \
    -not -path "*.git*" |  while read folder; do
        mkdir -pv "$(echo "${folder}" | sed "s_${PWD}_${HOME}_")"
    done
    
find "${PWD}" \
    -type f \
    -mindepth 2 \
    -not -path "*.git*" | while read file; do
        ln -sfnv "$file" "$(echo "${file}" | sed "s_${PWD}_${HOME}_")"
    done