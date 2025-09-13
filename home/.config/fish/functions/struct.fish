function struct-art
    clear
    echo "
      ▄████████     ███        ▄████████ ███    █▄   ▄████████     ███
      ███    ███ ▀█████████▄   ███    ███ ███    ███ ███    ███ ▀█████████▄
      ███    █▀     ▀███▀▀██   ███    ███ ███    ███ ███    █▀     ▀███▀▀██
      ███            ███   ▀  ▄███▄▄▄▄██▀ ███    ███ ███            ███   ▀
    ▀███████████     ███     ▀▀███▀▀▀▀▀   ███    ███ ███            ███
             ███     ███     ▀███████████ ███    ███ ███    █▄      ███
       ▄█    ███     ███       ███    ███ ███    ███ ███    ███     ███
     ▄████████▀     ▄████▀     ███    ███ ████████▀  ████████▀     ▄████▀
                               ███    ███
"
end

function struct-cmd-exist
    command --search --quiet "$argv"
end

function struct-cmd-missing
    not command --search --quiet "$argv"
end

function npc
    argparse n/no-newline -- $argv
    set str (string join " " $argv)

    while test -n "$str"
        printf "%s" (string sub -l 1 $str)
        set str (string sub -s 2 $str)
        sleep 0.01
    end

    if not set -q _flag_no_newline
        printf "\n"
    end
end

function recho
    printf "\033[A\033[K"
    echo $argv
end

function gum-random-spinner
    random choice line dot minidot jump pulse points meter hamburger
end

function struct-config
    struct-art
    #TODO show current value
    set which (gum choose --header="Choose your structure:" "dev" "prd" "custom")
    switch $which
        case dev
            set --universal struct_home "$HOME/Developer/struct/home"
        case env
            set --universal struct_home "$HOME/.local/share/struct/home"
        case other
            set --universal struct_home (gum file --directory $HOME --all)
    end
    test -d $struct_path && struct-sync || struct-config
end

function struct-init
    fish $struct_path/../main.fish
end

function struct-mode
    #TODO show current value
    struct-art
    if gum confirm "Choose your install:" --affirmative="Workstation" --negative="Server" --no-show-help
        set -Ux struct_mode "full"
    else
        set -Ux struct_mode "minimal"
    end
end

function struct-sync
    set --query struct_home || config

    function rehome
        string replace "$struct_path" "$HOME" "$argv"
    end

    struct-art
    echo "Linking from $struct_path..."

    # stage folders
find "$struct_path" -type d | while read folder
        mkdir -p "$(rehome "$folder")"
    end

    # link files
    find "$struct_path" -type f | while read file
        ln -sfv "$file" "$(rehome "$file")"
    end

    if struct-cmd-exist fd
        function fd_exclude
            fd . "$HOME" --hidden --exclude Developer --exclude Library --exclude Movies --exclude Music --exclude OrbStack --exclude Pictures --exclude Public --exclude ".Trash" $argv
        end
        # purge broken symlinks
        fd_exclude --type symlink --follow --exec rm
        # purge empty folders
        fd_exclude --type directory --type empty --hidden --exec rmdir
    end
end

function struct-done
    echo
    gum spin --spinner minidot --title "Done! Press any key to close..." -- read -n 1 -s
end

function struct
    argparse c/config m/mode s/sync i/init h/help -- $argv

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
        struct-config
        return 0
    end

    if set --query _flag_init
        struct-init
        return 0
    end

    if set --query _flag_mode
        struct-mode
        return 0
    end

    if set --query _flag_sync
        struct-sync
        return 0
    end

    clear
    struct-art
    # set command (gum choose Configure Initialize Synchronize)
    # switch $command
    #     case Configure
    #         config
    #     case Initialize
    #         config
    #     case Synchronize
    #         sync
    # end
    struct-sync
end
