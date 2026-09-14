function dfs-apply
    test -f $DOTFILES/.env; and source $DOTFILES/.env
    clear
    command cat $DOTFILES/art.txt

    if test -z "$DOTFILES_PROFILE"
        if gum confirm "Use full profile? Default: standard (10s timeout)." --timeout=10s --affirmative=yes --negative=no --default=false
            set -Ux DOTFILES_PROFILE full
        else
            set -Ux DOTFILES_PROFILE default
        end
    end

    for name in (dfs-layers)
        set layer $DOTFILES/setup/$name
        test -d $layer; or continue

        for script in $layer/*.fish
            set -q dfs_verbose[1]; and echo "RUN  "(string replace -- $HOME '~' $script)
            source $script
            set -l script_status $status
            if test $script_status -ne 0
                dfs-failure "Script failed: $script (exit $script_status)"
                return $script_status
            end
        end
    end

    dfs-link
    set -l link_status $status
    if test $link_status -ne 0
        dfs-failure "Managed symlink update failed"
        return $link_status
    end

    printf '\n%sSEE YOU SPACE COWBOY%s\n\n' (set_color --bold) (set_color normal)
end
