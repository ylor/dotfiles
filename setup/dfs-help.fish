function dfs-help --description "Show dfs usage"
    command cat (status dirname)/../art.txt
    printf '\n%s\n' 'Usage: dfs [options] [command]'
    printf '%s\n' \
        '' \
        'Options:' \
        '  -h, --help     Show help' \
        '  -v, --verbose  Print script paths during setup' \
        '' \
        'Commands:' \
        '  apply   Configure system (default)' \
        '  reset   Clear saved profile and reconfigure' \
        '  link    Update managed symlinks' \
        '  layers  List layers in application order' \
        '  help    Show help'
end
