#!/usr/bin/env sh
files=$(find . \
-type f \
-not -path "*.git/*" \
-not -path "./*.sh" \
-not -path "*.DS_Store" | sort)

for file in $files; do
    ln -sfnv "$file" $(echo $file | sed "s|\.|${HOME}|")
done