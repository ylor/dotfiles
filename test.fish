if type -q tput
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

function error
    printf "\r%s%sERROR%s %s%s\n" $BOLD $RED $RESET $argv $CLEAR_LINE
    exit 1
end

function success
    printf "\r%s%sSUCCESS%s %s%s\n" $BOLD $GREEN $RESET $argv $CLEAR_LINE
end

info "Linking dotfiles..."
sleep 1
success "Linked!"
