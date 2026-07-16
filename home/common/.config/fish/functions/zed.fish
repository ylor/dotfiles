if command -q zed zeditor # http://zed.dev
    function zed
        set --query argv[1]; or set argv "."
        set bin (command --search zed zeditor)[1]
        $bin $argv
    end
end
