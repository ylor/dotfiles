function touch
    mkdir -p (dirname "$argv")
    command touch $argv
end
