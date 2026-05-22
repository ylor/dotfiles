if command -q zoxide
    zoxide init fish | source

    function zd
        if not set -q argv[1]
            builtin cd
            return
        end

        builtin cd $argv 2>/dev/null
        or begin
            set dir (zoxide query -- $argv 2>/dev/null)
            and builtin cd $dir
            and echo (set_color green)✓(set_color normal) $PWD
        end
        or begin
            echo (set_color red)✗(set_color normal) "No such directory: \"$argv\"" >&2
            return 1
        end
    end

    # alias cd=zd
    # alias cdi=zi
    alias j=zd
    alias ji=zi
end
