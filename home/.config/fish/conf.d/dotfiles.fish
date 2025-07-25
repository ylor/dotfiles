function dotenv
    set which (gum choose "dev" "env" "other") # if var not set or flag is passed
    switch $which
    case 'dev'
        set --universal devenv "$HOME/Developer/env"
    case 'env'
        set --universal devenv "$HOME/.local/share/env"
    case 'other'
        set --universal devenv (gum file --directory $HOME --all)
    end
    echo $devenv
end

function dotlink
    set --query devenv || dotenv
    set --global home "$devenv/home"

    function rehome
        string replace "$home" "$HOME" "$argv"
    end

    # stage folders
    find "$home" -type d | while read folder
        mkdir -pv "$(rehome "$folder")"
    end

    # symlink dotfiles
    find "$home" -type f | while read file
        ln -sfv "$file" "$(rehome "$file")"
    end

    # # purge broken symlinks
    # find -L "$HOME" -type l -maxdepth 1 -exec rm {} \+
    # find -L "$HOME/.config" "$HOME/.local" -type l -exec rm {} \+

    # # purge empty folders
    # find "$HOME" -type d -maxdepth 1 -empty -delete
    # find "$HOME/.config" "$HOME/.local" -type d -empty -delete
end
