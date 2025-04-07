if command -q git # https://git-scm.com
    abbr --add g git

    abbr --command git b branch
    abbr --command git co checkout

    alias gb="git branch"
    alias gbd="git branch --delete"
    alias gco="git checkout"

    function git
        if [ $argv[1] = lol ]
            git add -A && git commit -m $(curl --silent --fail https://whatthecommit.com/index.txt) && git push
        else
            command git $argv
        end
    end
end

function quick-commit
    git add -A && git commit -m $(curl --silent --fail https://whatthecommit.com/index.txt) && git push
end

# Functions
function gc # git clone && cd to it
    set -f slashes (echo $argv | grep -o '/' | wc -l | tr -d ' ')
    set -f repo (switch $slashes
        case 0
            echo "https://github.com/ylor/$argv"
        case 1
            echo "https://github.com/$argv"
        case '*'
             echo $argv
    end)
    git clone $repo && cd "$(basename "$repo" .git)"
end

function git-me
    git config --global user.email 2200609+ylor@users.noreply.github.com
    git config --global user.name ylor
end

function git-papa
    git config --global user.email rreyes@papa.com
    git config --global user.name papa-rreyes
end
