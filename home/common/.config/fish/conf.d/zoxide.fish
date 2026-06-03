if command -q zoxide
    zoxide init fish | source

    function j
        builtin cd $argv 2>/dev/null && return

        if set -l dir (zoxide query -- $argv 2>/dev/null) && builtin cd $dir
            echo (set_color green)✓(set_color --bold) $PWD
        else
            echo (set_color red)✗(set_color --reset) "No such directory:" (set_color --bold)$argv
            return 1
        end
    end

    alias h=j
    alias ji=zi
    complete --command j --erase
    complete --command j --arguments "(zoxide query --list \$TOKEN 2>/dev/null)"
    complete --command j --force-files
end
