function dfs --description "Configure the system and manage linked files"
    set root (path resolve (path dirname (status filename))/..)

    set command apply
    if set -q argv[1]
        set command $argv[1]
        set --erase argv[1]
    end

    switch $command
        case apply reset
            if test $command = reset
                set --erase DOTFILES_PROFILE
            end
            dfs-apply $root $argv
        case link
            set -gx DOTFILES $root
            set --prepend fish_function_path "$root/home/base/.config/fish/functions" "$root/functions"
            dfs-link
        case help -h --help
            printf '%s\n' \
                'DFS / SYSTEM CONFIGURATION' \
                '' \
                'USAGE' \
                '  dfs [operation]' \
                '' \
                'OPERATIONS' \
                '  apply    Configure the system. This is the default operation.' \
                '  link     Establish managed file links without configuring the system.' \
                '  reset    Clear the saved profile selection, then configure the system.' \
                '  help     Display this operation reference.'
        case '*'
            printf 'DFS / UNKNOWN OPERATION / %s\n' $command >&2
            printf 'AVAILABLE OPERATIONS / dfs help\n' >&2
            return 2
    end
end
