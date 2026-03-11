function fish_title
    set -q SSH_CLIENT SSH_TTY && echo "[$(prompt_hostname)] "

    if [ $PWD = $HOME ]
        echo 👻
    else if set -q argv[1]
        echo $argv
    else
        string match -r '[^/]*$' $PWD
    end
end
