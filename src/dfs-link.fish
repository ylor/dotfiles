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

    set removed
    for link in $old
        contains -- $link $links; and continue
        test -L $link; or continue
        string match -q "$DOTFILES/*" (readlink $link); or continue
        rm $link
        set -a removed $link
    end

    if set -q removed[1]
        for link in $removed
            echo (set_color red)"✗"(set_color normal)" $link"
        end
        echo (set_color red)"✗"(set_color normal)" $(count $removed) files removed"
    end

    printf '%s\n' $old $links | sort -u >$manifest
    dfs-success "$(count $links) files linked"
end
