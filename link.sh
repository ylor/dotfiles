#!/usr/bin/env sh
folders=$(find $PWD \
-type d \
-not -path "$PWD" \
-not -path "*.git*" | sed "s|$PWD|$HOME|" | tr '\n' ' ')

echo mkdir -p "$folders"


files=$(find "$PWD" \
-type f \
-not -path "*.git*" \
-not -path "./*.sh" \
-not -path "*.DS_Store" | sort)
for file in $files; do
    ln -sfnv "$file" "$(echo "$file" | sed "s|$PWD|$HOME|")"
done