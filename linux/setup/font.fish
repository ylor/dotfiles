set font_directory $DOTFILES/home/.local/share/fonts
set destination_directory $HOME/.local/share/fonts

mkdir -p $destination_directory
set fonts_added 0

for font in $font_directory/*.age
    set filename (path basename $font | string sub --end -4 | base64 -d)
    set destination $destination_directory/$filename

    if not test -f $destination
        age -d -o $destination $font
        set fonts_added (math $fonts_added + 1)
    end
end

if test $fonts_added -gt 0; and command -vq fc-cache
    fc-cache -f $destination_directory
end

dfs-success "system / fonts"
