function exist
    command --search --quiet "$argv"
end

function missing
    not command --search --quiet "$argv"
end

function kernel
    string lower (uname -s)
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
    if not /usr/bin/sudo -n true 2>/dev/null
        gum input --password --placeholder="password" --no-show-help | sudo --validate --stdin
    end
    command /usr/bin/sudo $argv
end

function spinner
    random choice spinners line dot minidot jump pulse points meter hamburger
end
