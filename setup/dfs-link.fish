function dfs-link
    argparse q/quiet -- $argv; or return 2
    if not set -q DOTFILES
        dfs apply
        return $status
    end

    set links

    for name in (dfs-layers)
        set home $DOTFILES/home/$name
        test -d $home; or continue

        for file in (fd --hidden --absolute-path --type file --type symlink . $home)
            set link $HOME/(string replace -- "$home/" '' $file)
            mkdir -p (path dirname $link)
            ln -sf $file $link
            set --append links $link
        end
    end

    set state_home $XDG_STATE_HOME
    test -n "$state_home"; or set state_home $HOME/.local/state
    set manifest $state_home/dotfiles/manifest
    mkdir -p (path dirname $manifest)
    set removed

    for link in (cat $manifest 2>/dev/null)
        contains -- $link $links; and continue
        test -L $link; or continue
        string match -q "$DOTFILES/*" (readlink $link); or continue
        rm $link
        set --append removed $link
    end

    string join \n $links | sort -u >$manifest
    if not set -q _flag_quiet
        if test (count $removed) -gt 0
            dfs-success (count $removed)" obsolete managed file links removed."
        end
        dfs-success (count $links)" managed file links established."
    end
end
