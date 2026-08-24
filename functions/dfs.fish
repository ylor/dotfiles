function dfs --description "Manage the dotfiles"
    set root (path resolve (path dirname (status filename))/..)

    set command apply
    if set -q argv[1]
        set command $argv[1]
        set --erase argv[1]
    end

    switch $command
        case apply
            fish $root/main.fish $argv
        case link
            set -gx DOTFILES $root
            set --prepend fish_function_path "$root/home/.config/fish/functions" "$root/functions"
            dfs-link
        case reset
            fish $root/main.fish --reset $argv
        case help -h --help
            printf '%s\n' \
                'DFS / SYSTEM CONFIGURATION CONTROL' \
                '' \
                'USAGE / dfs [command]' \
                '' \
                'OPERATIONS' \
                '  apply    Execute complete system configuration. Default.' \
                '  link     Establish managed file links only.' \
                '  reset    Clear operator selections and execute configuration.' \
                '  help     Display command reference.'
        case '*'
            printf 'DFS / UNKNOWN COMMAND / %s\n' $command >&2
            printf 'REFERENCE / dfs help\n' >&2
            return 2
    end
end
