if command -vq zed zeditor # http://zed.dev
    function zed
        set zed (command -v zed-preview zed zeditor | head -n1)
        test (count $argv) -eq 0 && $zed . || $zed $argv
    end
end
