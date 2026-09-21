function fish_title
    set -q SSH_CONNECTION && printf '[%s] ' (prompt_hostname)
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
