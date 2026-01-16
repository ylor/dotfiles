function open
    set -l target $argv
    if test (count $argv) -eq 0
        set target .
    end

    if $DARWIN
        command open $target
    end

    if $LINUX
        xdg-open $target
    end
end
