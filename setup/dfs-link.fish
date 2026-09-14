function dfs-link
    set -l DOTFILES (path resolve (status dirname)/..)

    set links
    for layer in (dfs-layers)
        set home $DOTFILES/home/$layer
        test -d $home; or continue

        for file in (fd --hidden --absolute-path --type file --type symlink . $home)
            set link $HOME/(string replace -- "$home/" '' $file)
            mkdir -p (path dirname $link)
            ln -sf $file $link
            set --append links $link
        end
    end

    set manifest $HOME/.local/state/dotfiles/manifest
    mkdir -p (path dirname $manifest)

    set removed 0
    for link in (cat $manifest 2>/dev/null)
        contains -- $link $links; and continue
        test -L $link; or continue
        string match -q "$DOTFILES/*" (readlink $link); or continue
        rm $link
        set removed (math $removed + 1)
    end

    string join \n $links | sort -u >$manifest

    set -l summary (count $links)
    test $removed -gt 0; and set summary "$summary, −$removed"
    dfs-success "Dotfiles ($summary)"
end
