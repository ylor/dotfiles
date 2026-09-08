function dfs-apply
    argparse h/help -- $argv; or return 2
    if set -q _flag_help
        dfs-help
        return
    end

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
            set -q dfs_verbose; and echo "· run "(string replace -- $HOME '~' $script)
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

    printf '█ %sSEE YOU SPACE COWBOY%s\n\n' (set_color --bold --italics) (set_color normal)
end
