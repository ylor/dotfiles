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
