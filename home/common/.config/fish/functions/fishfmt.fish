function fishfmt
    set -q argv[1]; or set argv $PWD
    command fd --extension fish --type file --hidden --no-ignore . $argv --exec fish_indent --write
end
