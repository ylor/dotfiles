function editor
    set cmd (command -v zed-preview zed zeditor | head -n 1)
    switch (count $argv)
        case 0
            $cmd "$PWD"
        case '*'
            $cmd $argv
    end
end
