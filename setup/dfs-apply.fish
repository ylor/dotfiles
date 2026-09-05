function dfs-apply
    set root $argv[1]
    set --erase argv[1]

    argparse h/help -- $argv; or return 2
    if set -q _flag_help
        dfs help
        return
    end

    set -Ux DOTFILES $root
    set --prepend fish_function_path "$DOTFILES/home/base/.config/fish/functions" "$DOTFILES/setup"

    test -f $DOTFILES/.env; and source $DOTFILES/.env
    clear && command cat $DOTFILES/art.txt

    if test -z "$DOTFILES_PROFILE"
        if gum confirm "Use the Full profile? Standard is the default." --timeout=10s --affirmative=yes --negative=no --default=false
            set -Ux DOTFILES_PROFILE full
        else
            set -Ux DOTFILES_PROFILE default
        end
    end

    for name in (dfs-layers)
        set layer $DOTFILES/setup/$name
        test -d $layer; or continue

        for script in $layer/*.fish
            source $script
            or begin
                set -l failure_status $status
                printf '%s\n' \
                    'Configuration Error' \
                    '~~~ Script Failed ~~~' \
                    "ERROR MESSAGE: Could not run $script" >&2
                return $failure_status
            end
        end
    end

    dfs-fonts
    or begin
        set -l failure_status $status
        dfs-failure "Font installation failed."
        return $failure_status
    end

    dfs-link
    or begin
        set -l failure_status $status
        dfs-failure "Managed file linking failed."
        return $failure_status
    end

    printf '\n%sConfiguration Complete%s\nThe system is ready.\n\n' (set_color --bold) (set_color normal)
end
