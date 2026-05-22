function dfs-link
    argparse m/minimal q/quiet -- $argv
    set --query DOTFILES || dfs

    set kernel (uname | string lower)
    set originals (fd . "$DOTFILES/common/home" "$DOTFILES/$kernel/home" --hidden --absolute-path --type file)
    set links (string replace -r "$DOTFILES/(common|$kernel)/home" "$HOME" $originals)

    mkdir -p (path dirname $links | sort -u)
    for i in (seq (count $originals))
        ln -sfv $originals[$i] $links[$i]
        # set --query _flag_minimal || set --query _flag_quiet || dfs-success $links[$i]
    end

    set cache "$HOME/.cache/dotfiles/cache"
    mkdir -p (path dirname $cache)
    touch $cache

    string join \n $links | sort >$cache.new

    set stale (comm -23 $cache $cache.new)
    if test (count $stale) -gt 0
        rm $stale
        rmdir (path dirname $stale | sort -u)
    end
    mv $cache.new $cache

    # set --query _flag_quiet || dfs-success "$(count $links) files linked"
end
