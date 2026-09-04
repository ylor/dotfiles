function dfs-apply
    set root $argv[1]
    set --erase argv[1]

    argparse h/help -- $argv; or return 2
    if set -q _flag_help
        dfs help
        return
    end

    set -Ux DOTFILES $root
    set --prepend fish_function_path "$DOTFILES/home/base/.config/fish/functions" "$DOTFILES/functions"

    test -f $DOTFILES/.env; and source $DOTFILES/.env
    clear && command cat $DOTFILES/art.txt

    if test -z "$DOTFILES_PROFILE"
        if gum confirm "CONFIGURATION PROFILE / USE FULL PROFILE? DEFAULT / STANDARD" --timeout=10s --affirmative=yes --negative=no --default=false
            set -Ux DOTFILES_PROFILE full
        else
            set -Ux DOTFILES_PROFILE default
        end
    end

    set os (uname -s | string lower)
    set distro
    if test "$os" = linux; and test -r /etc/os-release
        set distro (string replace -r '^ID=' '' (string match -r '^ID=.*' </etc/os-release) | string trim -c '"')
    end

    set layers $DOTFILES/setup/base $DOTFILES/setup/$os
    test -n "$distro"; and set --append layers $DOTFILES/setup/$os/$distro

    for layer in $layers
        test -d $layer; or continue

        set scripts $layer/*.fish
        if test -f $layer/system.fish
            set scripts $layer/system.fish (string match -v $layer/system.fish $scripts)
        end

        for script in $scripts
            if not source $script
                dfs-failure "configuration / failed / $script"
                return 1
            end
        end
    end

    if not dfs-fonts
        dfs-failure "fonts / installation failed"
        return 1
    end

    if not dfs-link
        dfs-failure "managed files / linking failed"
        return 1
    end

    printf '█ %sCONFIGURATION COMPLETE%s\n\n' (set_color --bold) (set_color normal)
    exec fish
end
