function touch
    command mkdir -p (path dirname -- $argv)
    command touch -- $argv
end

alias tch=touch
