command -vq zeditor && alias zed="zeditor"
if command -vq zed # http://zed.dev
    function zed
        set --local zed (which zed-preview || which zed)
        test (count $argv) -eq 0 && $zed . || $zed $argv
    end
end
