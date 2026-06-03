function dfs-link
    set --query DOTFILES || dfs
    argparse c/count v/verboase m/minimal q/quiet -- $argv; or return 1

    set kernel (uname | string lower)
    set dirs (path filter --type dir $DOTFILES/home/{common,$kernel})
    set files (fd . $dirs --hidden --absolute-path --type file)
    set links (string replace --regex "^$DOTFILES/home/(common|$kernel)" "$HOME" $files)
    mkdir -p (path dirname $links | sort --unique)
    for i in (seq (count $files))
        ln -sf $files[$i] $links[$i]
        dfs-success $links[$i]
    end

    set manifest $DOTFILES/home/manifest
    for link in (cat $manifest 2>/dev/null)
        contains -- $link $links; and continue
        if test -L $link; and string match --quiet -- "$DOTFILES/*" (path resolve $link)
            rm $link
        end
    end
    # mkdir -p (path dirname $manifest)
    string join \n $links >$manifest

    #set -q _flag_count; and dfs-success "$(count $links) files linked"
    dfs-success "$(count $links) files linked"
end
