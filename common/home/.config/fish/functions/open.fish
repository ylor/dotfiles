function open
    set -l target $argv
    set -q argv[1]; or set target .
    switch $KERNEL
        case darwin
            command open $target
        case linux
            xdg-open $target
    end
end
