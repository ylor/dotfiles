function dot-show-art
    clear
    cat $DOT_PATH/art.txt
    echo
end

function dot-cmd-exist
    command --search --quiet "$argv"
end

function dot-cmd-missing
    not command --search --quiet "$argv"
end

function dot-npc
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

function dot-reverb
    printf "\033[A\033[K"
    echo $argv
end

function dot-config
    dot-show-art
    if gum confirm "Choose your style:" --affirmative="Full" --negative="Minimal" --no-show-help
        set -Ux DOT_MODE full
    else
        set -Ux DOT_MODE minimal
    end
end

function dot-help
    echo "Usage: dot [OPTIONS]

Options:
-h, --help          Show this message
-c, --config        Configure environment
-i, --init          Initialize system
-s, --sync          Synchronize dotfiles
-t, --tui           Terminal UI
"
    return
end

function dot-init
    fish $DOT_PATH/main.fish
end

function dot-sync
    dot-show-art
    set --query DOT_HOME || return 67

    function rehome
        string replace "$DOT_HOME" "$HOME" "$argv"
    end

    echo "Linking from $DOT_HOME..."

    # stage folders
    find "$DOT_HOME" -type d | while read folder
        mkdir -p "$(rehome "$folder")"
    end

    # link files
    find "$DOT_HOME" -type f | while read file
        ln -sfv "$file" "$(rehome "$file")"
    end

    if dot-cmd-exist fd
        function fd_exclude
            fd . "$HOME" --hidden --exclude Developer --exclude Library --exclude Movies --exclude Music --exclude OrbStack --exclude Pictures --exclude Public --exclude ".Trash" $argv
        end

        # purge broken symlinks
        fd_exclude --type symlink --follow --exec rm
        # purge empty folders
        fd_exclude --type directory --type empty --hidden --exec rmdir
    end
end

function dot-tui
    set command (gum choose "Configure" "Initialize" "Synchronize")
    switch $command
        case Configure
            dot-config
        case Initialize
            dot-init
        case Synchronize
            dot-sync
        case '*'
            return 67
    end
end

function dot
    dot-show-art
    argparse h/help c/config i/init s/sync t/tui -- $argv

    set --query _flag_help && dot-help && return 0
    set --query _flag_config && dot-config && return 0
    set --query _flag_init && dot-init && return 0
    set --query _flag_sync && dot-sync && return 0
    set --query _flag_tui && dot-tui && return 0
    dot-sync
end
