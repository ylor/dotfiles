function exist
    command --search --quiet "$argv"
end

function missing
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

function spinner
    random choice line dot minidot jump pulse points meter hamburger
end
