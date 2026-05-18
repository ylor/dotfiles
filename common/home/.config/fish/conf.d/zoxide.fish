if command -q zoxide # https://github.com/ajeetdsouza/zoxide - smarter cd
    zoxide init fish | source

    function zd
        if not set -q argv[1]
            builtin cd $HOME
        else if test -d $argv[1]
            builtin cd $argv[1]
        else if set -l dir (zoxide query -- $argv 2>/dev/null)
            builtin cd $dir
            echo (set_color green)✓(set_color normal) $PWD
        else
            false
        end
    end

    alias cd="zd"
    alias cdi="zi"
    alias j="zd"
    alias ji="zi"
end
