function visual
    set cmd "vim"
    switch (count $argv)
        case 0
            $cmd "$PWD"
        case '*'
            $cmd $argv
    end
end
