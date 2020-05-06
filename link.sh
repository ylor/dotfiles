#!/usr/bin/env sh
folders=$(find "$PWD" \
-type d \
-not -path "$PWD" \
-not -path "*.git*")
files=$(find "$PWD" \
-type f \
-not -path "*.git*" \
-not -path "./*.sh" \
-not -path "*.DS_Store" | sort)

mkdir -p "$(echo "$folders" | sed "s|$PWD|$HOME|")"

for file in $files; do
    ln -sfnv "$file" "$(echo "$file" | sed "s|$PWD|$HOME|")"
done