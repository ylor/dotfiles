#!/usr/bin/env sh
for folder in */; do
	stow -t "$HOME" "$folder"
done
