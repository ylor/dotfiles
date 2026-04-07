function dfs-reverb
    # printf "\033[A\033[K$argv\n"
    # tput cuu1 # cursor up 1
    # tput el # erase line
    # echo $argv
    printf "\033[A\033[K%s\n" (string join ' ' $argv)
end
