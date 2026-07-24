function fish_title
    set -q SSH_CLIENT SSH_TTY && echo "[$(prompt_hostname)] "
    set -l command (status current-command)

    if test "$command" != fish
        echo $command
    else if test $PWD = $HOME
        echo 👻
    else
        path basename $PWD
    end
end
