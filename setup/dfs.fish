function dfs --description "Configure the system and manage linked files"
    set root (path resolve (path dirname (status filename))/..)

    switch "$argv[1]"
        case '' apply reset
            test "$argv[1]" = reset; and set --erase DOTFILES_PROFILE
            dfs-apply $root $argv[2..]; or return $status
            contains -- --help $argv; and return 0
            contains -- -h $argv; and return 0
            exec fish
        case link
            set -gx DOTFILES $root
            set --prepend fish_function_path "$root/home/base/.config/fish/functions" "$root/setup"
            dfs-link
        case help -h --help
            printf '%s\n' \
                'Dotfiles' \
                'System Configuration / DF-01' \
                '' \
                'Usage' \
                '  dfs [operation]' \
                '' \
                'Operations' \
                '  apply   Configure the system. Default.' \
                '  link    Establish managed file links.' \
                '  reset   Clear the saved profile and configure the system.' \
                '  help    Display this reference.'
        case '*'
            printf '%s\n' \
                'Command Error' \
                "~~~ Unknown Operation: $argv[1] ~~~" \
                'ERROR MESSAGE: The requested operation is not available.' \
                'RECOVERY: Run dfs help.' >&2
            return 2
    end
end
