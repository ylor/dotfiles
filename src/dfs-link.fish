function dfs-link
    argparse m/minimal q/quiet -- $argv; or return 1

    set --query DOTFILES || dfs

    # 2. Get valid source directories using Fish's built-in 'path filter'
    set kernel (uname | string lower)
    set src_dirs (path filter -d "$DOTFILES/common/home" "$DOTFILES/$kernel/home")
    test -n "$src_dirs"; or return 0

    # 3. Gather source files and initialize link tracking
    set originals (fd . $src_dirs --hidden --absolute-path --type file)
    set -l links

    # 4. Single loop to map, build directories, and symlink
    for src in $originals
        set dst (string replace -r "^$DOTFILES/(common|$kernel)/home" "$HOME" $src)
        set -a links $dst

        mkdir -p (path dirname $dst)
        ln -sfv $src $dst

        # set -q _flag_minimal; or set -q _flag_quiet; or dfs-success $dst
    end

    # 5. Clean up stale links using clean in-memory matching
    set cache "$HOME/.cache/dotfiles/cache"
    if test -f $cache
        for old_link in (cat $cache)
            if not contains $old_link $links
                rm -f $old_link
                rmdir (path dirname $old_link) 2>/dev/null
            end
        end
    end

    # 6. Update cache file
    mkdir -p (path dirname $cache)
    string join \n $links > $cache

    # set -q _flag_quiet; or dfs-success "$(count $links) files linked"
end
