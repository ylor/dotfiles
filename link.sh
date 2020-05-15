#!/usr/bin/env sh
# Find all necesssary folders that symlinks succeed
folders=$(find $PWD \
-type d \
-not -path "$PWD" \
-not -path "*.git*" | sort | sed "s|$PWD|$HOME|")
# Make those necessary directories
for folder in $folders; do
    mkdir -pv "$folder"
done

# Find all dotfiles we'd like to symlink
files=$(find "$PWD" \
-type f \
-not -path "*.git*" \
-not -path "./*.sh" \
-not -path "*.DS_Store" | sort)
# Symlink them
for source in $files; do
    target=$(echo "$source" | sed "s|$PWD|$HOME|")
    ln -sfnv "$source" "$target"
done
