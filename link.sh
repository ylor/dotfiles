#!/usr/bin/env sh
for folder in */; do
	stow "$folder" --target "$HOME" 
done
