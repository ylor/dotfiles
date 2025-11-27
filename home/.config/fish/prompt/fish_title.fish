function fish_title
    if [ $PWD = $HOME ]
        echo 👻
    else
        set -q SSH_CLIENT SSH_TTY && echo "[$(prompt_hostname)]"

        if set -q argv[1]
            echo $argv
        else
            echo (string replace -r '.*/' '' $PWD)
        end
    end
end
