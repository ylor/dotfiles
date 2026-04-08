function dfs-link
    argparse m/minimal q/quiet -- $argv
    set --query DOTFILES || dfs

    set cache "$HOME/.cache/dotfiles/cache"
    mkdir -p (path dirname $cache)
    touch $cache

    set kernel (uname | string lower)
    set originals (fd . "$DOTFILES/common/home" "$DOTFILES/$kernel/home" --hidden --absolute-path --type file)
    set links (string replace -r "$DOTFILES/(common|$kernel)/home" "$HOME" $originals)

    mkdir -p (path dirname $links | sort -u)
    for i in (seq (count $originals))
        ln -sf $originals[$i] $links[$i]
        set --query _flag_minimal || set --query _flag_quiet || dfs-success $links[$i]
    end

    string join \n $links | sort >$cache.new
    set stale (comm -23 $cache $cache.new)
    rm $stale 2>/dev/null
    rmdir (path dirname $stale | sort -u) 2>/dev/null
    mv $cache.new $cache

    set --query _flag_quiet || dfs-success "$(count $links) files linked"
end
