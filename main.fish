#!/usr/bin/env fish

set root (path resolve (status dirname))
set --prepend fish_function_path "$root/home/base/.config/fish/functions" "$root/setup"

# Keep credentials fresh after the first privileged command authenticates.
sh -c 'while true; do sudo -n -v 2>/dev/null; sleep 60; done' &
set -g dfs_sudo_keepalive $last_pid

function dfs-stop-sudo-keepalive --on-event fish_exit
    kill $dfs_sudo_keepalive 2>/dev/null
end

dfs $argv
