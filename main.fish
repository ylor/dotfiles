#!/usr/bin/env fish

set root (path resolve (status dirname))
set --prepend fish_function_path "$root/home/base/.config/fish/functions" "$root/functions"

dfs $argv
