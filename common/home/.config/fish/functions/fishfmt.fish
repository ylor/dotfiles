function fishfmt
    fd --hidden --type f .fish --exec-batch fish_indent --write $argv
end
