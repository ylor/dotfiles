function art
    clear
    echo "
   ███████ ██ ██      ███████ ███████
   ██      ██ ██      ██      ██
   █████   ██ ██      █████   ███████
   ██      ██ ██      ██           ██
██ ██      ██ ███████ ███████ ███████
"
end

function config
    art
    set which (gum choose --header="Choose environment:" "dev" "env" "other")
    switch $which
        case dev
            set --universal devenv "$HOME/Developer/env/home"
        case env
            set --universal devenv "$HOME/.local/share/env/home"
        case other
            set --universal devenv (gum file --directory $HOME --all)
    end
    test -d $devenv && sync || config
end

function init
    function os_is_mac
        test (uname) = Darwin
    end

    function os_is_linux
        test (uname) = Linux
    end

    function linux_is_arch
        command -vq pacman
    end

    if os_is_mac
        echo mac
    else if os_is_linux && linux_is_arch
        echo arch
    end
end

function sync
    set --query devenv || config

    function rehome
        string replace "$devenv" "$HOME" "$argv"
    end

    art
    echo "Linking from $devenv..."

    # stage folders
    find "$devenv" -type d | while read folder
        mkdir -p "$(rehome "$folder")"
    end

    # # symlink dotfiles
    find "$devenv" -type f | while read file
        ln -sfv "$file" "$(rehome "$file")"
    end

    if exist fd
        function fd_exclude
            fd . "$HOME" --hidden --exclude "Developer" --exclude "Library" --exclude "Movies" --exclude "Music" --exclude "OrbStack" --exclude "Pictures" --exclude "Public" --exclude ".Trash" $argv
        end
        # purge broken symlinks
        fd_exclude --type symlink --follow --exec rm
        # purge empty folders
        fd_exclude --type directory --type empty --hidden --exec rmdir
    end
end

function done
    echo
    gum spin --spinner minidot --title "Done! Press any key to close..." -- read -n 1 -s
end

function dot
    argparse c/config s/sync i/init h/help -- $argv

    if set --query _flag_help
        echo "Usage: link [OPTIONS]

Options:
-c, --config        Configure environment
-i, --init          Initialize machine
-s, --sync          Synchronize dotfiles
-h, --help          Show this message"
        return 0
    end

    if set --query _flag_config
        config
        return 0
    end

    if set --query _flag_init
        init
        return 0
    end

    if set --query _flag_sync
        sync
        return 0
    end

    clear
    art
    # set command (gum choose Configure Initialize Synchronize)
    # switch $command
    #     case Configure
    #         config
    #     case Initialize
    #         config
    #     case Synchronize
    #         sync
    # end
    sync
end
