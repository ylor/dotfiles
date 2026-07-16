function md --wraps mkdir
    mkdir -p $argv
    test (count $argv) -eq 1; or return 0
    builtin cd $argv
end
