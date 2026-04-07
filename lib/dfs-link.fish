function dfs-link
    set --query DOTFILES || dfs
    set cache "$HOME/.cache/dotfiles/cache"
    mkdir -p (path dirname $cache)
    touch $cache

    set links
    for orig in (fd . "$DOTFILES/home" --hidden --absolute-path --type file)
        set link (string replace "$DOTFILES/home" "$HOME" "$orig")
        set --append links $link

        mkdir -p (path dirname $link)
        ln -sf $orig $link
        # dfs-success $link
    end

    printf '%s\n' $links | sort >$cache.tmp
    set stale (comm -23 $cache $cache.tmp)
    rm $stale 2>/dev/null
    mv $cache.tmp $cache

    rmdir (path dirname (cat $cache) | sort -u) 2>/dev/null
    dfs-success "$(count $links) files linked"
    # dfs-success "dotfiles linked!"
end
