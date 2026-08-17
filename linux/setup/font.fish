set font_directory $DOTFILES/assets/fonts
set destination_directory $HOME/.local/share/fonts
set installed_font false

mkdir -p $destination_directory

for font in $font_directory/*.age
    set filename (path basename $font | string replace -r '\.age$' '' | base64 -d)
    set destination $destination_directory/$filename

    if not test -f $destination
        age -d -o $destination $font
        and set installed_font true
    end
end

if $installed_font; and command -vq fc-cache
    fc-cache -f $destination_directory
end
