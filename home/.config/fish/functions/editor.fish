function editor
    set $cmd (which zed-preview || which zed || which zeditor)
    switch (count $argv)
        case 0
            $cmd "$PWD"
        case '*'
            $cmd $argv
    end
end
