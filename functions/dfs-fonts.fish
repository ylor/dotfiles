function dfs-fonts --description "Install the managed typefaces"
    set font_directory $DOTFILES/home/base/.local/assets

    switch (uname -s)
        case Darwin
            set destination_directory $HOME/Library/Fonts
        case Linux
            set destination_directory $HOME/.local/share/fonts
        case '*'
            dfs-failure "fonts / unsupported platform / "(uname -s)
            return 1
    end

    mkdir -p $destination_directory; or return 1

    set fonts_added 0
    for font in $font_directory/*.age
        set filename (path basename $font | string sub --end -4 | base64 -d)
        set destination $destination_directory/$filename

        if not test -f $destination
            age -d -o $destination $font; or return 1
            set fonts_added (math $fonts_added + 1)
        end
    end

    if test (uname -s) = Linux; and test $fonts_added -gt 0; and command -vq fc-cache
        fc-cache -f $destination_directory; or return 1
    end

    dfs-success "fonts / installed"
end
