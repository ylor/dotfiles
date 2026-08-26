function dfs-link
    argparse q/quiet -- $argv; or return 2
    if not set -q DOTFILES
        dfs apply
        return $status
    end

    set os (uname -s | string lower)
    set host (hostname -s | string lower)
    set homes $DOTFILES/home $DOTFILES/$os/home $DOTFILES/$os/hosts/$host/home
    set links

    for home in $homes
        test -d $home; or continue

        for file in (fd . $home --hidden --absolute-path --type file --type symlink)
            set link $HOME/(string replace "$home/" "" $file)
            mkdir -p (path dirname $link)
            ln -sf $file $link
            set --append links $link
            # dfs-success $link
        end
    end

    set manifest $DOTFILES/.manifest
    set old (cat $manifest 2>/dev/null)
    set removed

    for link in $old
        contains -- $link $links; and continue
        test -L $link; or continue
        string match -q "$DOTFILES/*" (readlink $link); or continue
        rm $link
        set --append removed $link
        # echo "✗ $link"
    end

    string join \n $links | sort -u >$manifest
    if not set -q _flag_quiet
        if test (count $removed) -gt 0
            printf '▓ DOTFILES / REMOVED / %s\n' (count $removed)
        end
        dfs-success "dotfiles / linked ($(count $links))"
    end
end
