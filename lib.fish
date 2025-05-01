function exist
    command --search --quiet "$argv"
end

function missing
    not command --search --quiet "$argv"
end

if exist tput
    set RESET (tput sgr0)
    set BOLD (tput bold)
    set RED (tput setaf 1)
    set GREEN (tput setaf 2)
    set BLUE (tput setaf 4)
    set CLEAR_LINE (tput el)
end

function info
    printf "\r%s%sINFO%s %s" $BOLD $BLUE $RESET $argv
end

function success
    printf "\r%s%sSUCCESS%s %s%s\n" $BOLD $GREEN $RESET $argv $CLEAR_LINE
end

function error
    printf "\r%s%sERROR%s %s%s\n" $BOLD $RED $RESET $argv $CLEAR_LINE
    exit 1
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

function run
    info $argv
    source $argv && success $argv || error $argv
end

function spin
    exist gum || error "`gum` is missing"
    argparse 't/title=' 'c/command=' -- $argv || return
    set spinners line dot minidot jump pulse points meter hamburger
    set spinner (random choice $spinners)
    eval "gum spin --spinner="$spinner" --title="$_flag_title "-- "$_flag_command""
end

function check_sudo
    if sudo -n true
        spin -- sudo $argv
    else
        sudo $argv
    end
end
