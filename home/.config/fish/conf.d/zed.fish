if command -vq zed # http://zed.dev
    command -vq zeditor && alias zed="zeditor"
    function zed
        set --local zed (which zed-preview || which zed)
        test (count $argv) -eq 0 && $zed . || $zed $argv
    end
end
