function exist
    command --search --quiet "$argv"
end

function missing
    not exist "$argv"
end

function kernel
    string lower (uname -s)
end

function link
    set --global home (realpath "$(status dirname)/home")

    function rehome
        string replace "$home" "$HOME" "$argv"
    end

    # # stage folders
    # find "$home" -type d | while read folder
    #     mkdir -p "$(rehome "$folder")"
    # end

    # # symlink dotfiles
    # find "$home" -type f | while read file
    #     ln -sf "$file" "$(rehome "$file")"
    # end
end

function npc
    argparse n/no-newline -- $argv
    set str (string join " " $argv)

    # print each character with delay
    while test -n "$str"
        printf "%s" (string sub -l 1 $str)
        set str (string sub -s 2 $str)
        sleep 0.01
    end

    # add newline if needed
    if not set -q _flag_no_newline
        printf "\n"
    end
end

function pls
    exist gum || error "`gum` is missing"
    if not sudo -n true 2>/dev/null
        gum input --password --placeholder="password" --no-show-help | sudo --validate --stdin
    end
    command sudo $argv
end

function spinner
    random choice spinners line dot minidot jump pulse points meter hamburger
end
