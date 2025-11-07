function open
    test (count $argv) -eq 0 && open . || open $argv
end