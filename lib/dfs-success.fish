function dfs-success
    printf '%s✓%s %s\n' (set_color green) (set_color normal) "$argv"
    # printf "$(set_color green)✓ $(set_color normal) $argv"
    # set_color normal && dfs-npc "$argv"
    # set_color normal && echo "$argv"
    # echo "$(set_color green)✓ $(set_color normal)$argv"
end
