set fish_session 0
function fish_title
    if [ $fish_session -eq 0 ] || [ $PWD = $HOME ]
        echo 👻
        set fish_session 1
    else
        set --query SSH_CLIENT || set --query SSH_TTY && set --local ssh "[$(prompt_hostname )]" # check if SSH

        if set -q argv[1]
            echo $ssh $argv[1]
        else
            set -l command (status current-command)
            [ "$command" = fish ] && set command # Don't print "fish" because it's redundant
            echo $ssh $command (basename $PWD)
        end
    end
end