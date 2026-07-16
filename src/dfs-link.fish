function dfs-link
    set -q DOTFILES; or dfs

    set kernel (string lower (uname))
    set dirs (path filter -d $DOTFILES/home/{common,$kernel})
    set files (fd . $dirs --hidden --absolute-path --type file)
    set links (string replace -r "^$DOTFILES/home/(common|$kernel)" "$HOME" $files)

    # link
    mkdir -p (path dirname $links | sort -u)
    for i in (seq (count $files))
        ln -sf $files[$i] $links[$i]
        dfs-success $links[$i]
    end

    # prune
    set manifest $DOTFILES/home/manifest
    set old (cat $manifest 2>/dev/null)
    set removed 0
    for link in $old
        contains -- $link $links; and continue
        test -L $link; or continue
        string match -q "$DOTFILES/*" (readlink $link); or continue
        rm $link
        echo "✗ $link"
        set removed (math $removed + 1)
    end
    test $removed -gt 0; and echo "✗ $removed files removed"

    # record everything ever linked (stale entries kept on purpose)
    string join \n $old $links | sort -u >$manifest
    dfs-success "$(count $links) files linked"
end
