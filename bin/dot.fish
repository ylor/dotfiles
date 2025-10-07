for cmd in $DOT_PATH/bin/*.fish
    source $cmd
end

function dot
    dot-show-art
    argparse h/help c/config i/init s/sync t/tui -- $argv

    set --query _flag_help && dot-help && return 0
    set --query _flag_config && dot-config && return 0
    set --query _flag_init && dot-init && return 0
    set --query _flag_sync && dot-sync && return 0
    set --query _flag_tui && dot-tui && return 0
    dot-sync
end
