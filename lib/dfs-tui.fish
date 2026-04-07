#!/usr/bin/env fish
dfs-show-art
set choice (gum choose  "Configure" "Initialize" "Synchronize" "Abort")
switch $choice
    case Configure
        dfs-config
    case Initialize
        dfs-init
    case Synchronize
        dfs-sync
    case '*'
        exit 67
end
