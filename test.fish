function npc
    argparse n/no-newline -- $argv
    set str (string join " " $argv)
    # Print each character with delay
    while test -n "$str"
        printf "%s" (string sub -l 1 $str)
        set str (string sub -s 2 $str)
        sleep 0.01
    end

    # Add newline if needed
    if not set -q _flag_no_newline
        printf "\n"
    end
end
