set font_directory $DOTFILES/assets/fonts
set destination_directory $HOME/Library/Fonts

mkdir -p $destination_directory

for font in $font_directory/*.age
    set filename (path basename $font | string replace -r '\.age$' '' | base64 -d)
    set destination $destination_directory/$filename

    if not test -f $destination
        age -d -o $destination $font
    end
end
