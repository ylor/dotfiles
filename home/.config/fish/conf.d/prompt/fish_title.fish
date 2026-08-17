function fish_title
    set -q SSH_CLIENT SSH_TTY && echo "[$(prompt_hostname)] "
    set -l command (status current-command)

    if test $command = fish
        if test $PWD = $HOME
            echo 👻
        else
            path basename $PWD
        end
    else
        echo $command
    end
end
