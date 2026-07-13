function dfs-link
    set -q DOTFILES; or dfs
    argparse c/count v/verbose m/minimal q/quiet -- $argv; or return

    set kernel (string lower (uname))
    set dirs (path filter -d $DOTFILES/home/{common,$kernel})
    set files (fd . $dirs --hidden --absolute-path --type file)
    set links (string replace -r "^$DOTFILES/home/(common|$kernel)" "$HOME" $files)
    set manifest $DOTFILES/home/manifest
    set old (cat $manifest 2>/dev/null)

    mkdir -p (path dirname $links | sort -u)

    for i in (seq (count $files))
        ln -sf $files[$i] $links[$i]
        dfs-success $links[$i]
    end

    for link in $old
        contains -- $link $links; and continue
        test -L $link; or continue
        string match -q "$DOTFILES/*" (readlink $link); or continue
        rm $link
    end

    printf '%s\n' $old $links | sort -u >$manifest
    dfs-success "$(count $links) files linked"
end
