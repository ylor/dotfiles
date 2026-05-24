function fish_title
    set -q SSH_CLIENT SSH_TTY && echo "[$(prompt_hostname)] "
    # set -q SSH_CLIENT SSH_TTY && echo "❬$(prompt_hostname)❭ "

    if test $PWD = $HOME
        echo 👻
    else if set -q argv[1]
        echo $argv
    else
        path basename $PWD
    end
end
