function fish_title
    if [ $PWD = $HOME ]
        echo 👻
    else
        set -q SSH_CLIENT SSH_TTY && set ssh "[$(prompt_hostname )]"
        set dir (string split '/' (prompt_pwd))[-1]
        echo "$ssh $dir"

        if string length --quiet "$argv"
            echo " – $argv"
        end
    end
end
