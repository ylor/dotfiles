#!/bin/sh

# Clean up broken symlinks
find -L "$HOME/.config" -type l -exec rm {} \;
# Find all necesssary folders that symlinks succeed
folders=$(
    find ${PWD} \
        -type d \
        -mindepth 1 \
        -not -path "*.git*" | sed "s_${PWD}_${HOME}_"
)
# Make those necessary directories
for folder in ${folders}; do
    mkdir -pv "${folder}"
done

# Find all dotfiles we'd like to symlink
files=$(
    find "${PWD}" \
        -type f \
        -not -name "Brewfile*" \
        -not -name "*.DS_Store" \
        -not -path "*.git*" \
        -not -name "*.sh"
)
# Symlink them
for source in ${files}; do
    target=$(echo "${source}" | sed "s_${PWD}_${HOME}_")
    ln -sfnv "$source" "$target"
done
