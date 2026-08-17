function open
    set -q argv[1]; or set argv "."

    switch (uname -s)
        case Darwin
            command open $argv
        case Linux
            xdg-open $argv
        case '*'
            return 1
    end
end
