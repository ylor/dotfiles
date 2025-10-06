if command -vq zoxide # https://github.com/ajeetdsouza/zoxide - smarter cd
    zoxide init fish | source
    alias cd="zd"
    alias cdi="zi"
    alias j="zd"
    alias ji="zi"

    function zd
        if test (count $argv) -eq 0
            builtin cd $HOME
        else if test -d $argv
            builtin cd $argv
        else
            set dir (zoxide query $argv 2>/dev/null)
            if test $status -eq 0
                builtin cd $dir
                set_color green && printf "✓ "
                set_color normal && pwd
            else
                false
            end
        end
    end
end
