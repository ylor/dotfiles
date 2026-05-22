if command -vq zed zeditor # http://zed.dev
    function zed
        set zed (command -v zed zeditor)[1]
        set -q argv[1] && $zed $argv || $zed .
    end
end
