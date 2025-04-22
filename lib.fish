function exist
    command -vq $argv[1]
end

if command -vq tput
    set RESET (tput sgr0)
    set BOLD (tput bold)
    set RED (tput setaf 1)
    set GREEN (tput setaf 2)
    set BLUE (tput setaf 4)
else
    set RESET ""
    set BOLD ""
    set RED ""
    set GREEN ""
    set BLUE ""
end

function info
    printf "%s%sINFO%s %s\n" $BOLD $BLUE $RESET $argv
end

function error
    printf "%s%sERROR%s %s\n" $BOLD $RED $RESET $argv
    exit 1
end

function success
    printf "%s%sSUCCESS%s %s\n" $BOLD $GREEN $RESET $argv
end

function spin
    set spinners line dot minidot jump pulse points meter hamburger
    set spinner (random choice $spinners)
    gum spin --spinner=$spinner -- $argv
end
