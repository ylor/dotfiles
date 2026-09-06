function dfs-fonts --description "Install the managed typefaces"
    set platform (uname -s)

    switch $platform
        case Darwin
            set destination_directory $HOME/Library/Fonts
        case Linux
            set destination_directory $HOME/.local/share/fonts
        case '*'
            dfs-failure "Font installation is not available on $platform."
            return 1
    end

    mkdir -p $destination_directory; or return 1

    set fonts_added false
    for font in $DOTFILES/home/base/.local/assets/*.age
        set filename (path basename $font | string sub --end -4 | base64 -d)
        set destination $destination_directory/$filename
        test -f $destination; and continue

        age -d -o $destination $font; or return 1
        set fonts_added true
    end

    if test $platform = Linux; and $fonts_added; and command -vq fc-cache
        fc-cache -f $destination_directory; or return 1
    end

    if $fonts_added; and contains -- omarchy (dfs-layers)
        omarchy font set "Berkeley Mono Variable" >/dev/null 2>&1; or return 1
    end

    dfs-success "Fonts installed."
end
