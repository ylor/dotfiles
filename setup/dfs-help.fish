function dfs-help --description "Show dfs usage"
    command cat (status dirname)/../art.txt
    printf '\n%s\n' 'Usage: dfs [-v] [apply|reset|link|help]'
    printf '%s\n' \
        '' \
        '  apply   Configure the system (default).' \
        '  reset   Clear the saved profile and configure the system.' \
        '  link    Establish managed file links.' \
        '  help    Show this help.' \
        '' \
        '  -v, --verbose  Report each script as it runs.'
end
