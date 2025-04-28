function dot
    set --global home (realpath "$(status dirname)/home")

    function rehome
        string replace "$home" "$HOME" "$argv"
    end

    # stage folders
    find "$home" -type d | while read folder
        echo mkdir -pv "$(rehome "$folder")"
    end

    # symlink dotfiles
    find "$home" -type f | while read file
        echo ln -sfv "$file" "$(rehome "$file")"
    end

    # # purge broken symlinks
    # find -L "$HOME" -type l -maxdepth 1 -exec rm {} \+
    # find -L "$HOME/.config" "$HOME/.local" -type l -exec rm {} \+

    # # purge empty folders
    # find "$HOME" -type d -maxdepth 1 -empty -delete
    # find "$HOME/.config" "$HOME/.local" -type d -empty -delete
end

function findd
    if command -vq fd
        fd ".git" --hidden --type dir --max-depth 5 --exclude Library "$HOME"
    else
        find $HOME -path $HOME/Library -prune -o -maxdepth 5 -type d -name ".git" 2>/dev/null
    end
end

function homee
    for repo in (find $HOME -path $HOME/Library -prune -o -maxdepth 5 -type d -name ".git" 2>/dev/null)
        echo $repo
        if grep -q "url.*ylor/env.git" $repo/config
            echo (dirname $repo)
        end
    end
end

function chooseenv
    gum file --header="Set ENV" --height=50 --all --no-permissions --no-size --directory $HOME
end
