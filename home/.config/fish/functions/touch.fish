function touch
    command mkdir -p (dirname "$argv")
    command touch $argv
end
