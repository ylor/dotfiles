if command -vq git # https://git-scm.com
    alias gb="git branch"
    alias gco="git checkout"
    alias gp="git pull"
    alias gr="git-root"

    function git
        switch $argv[1]
            case convert
                git-convert
            case me
                git-me
            case lol
                git add -A
                git commit -m $(curl --silent --fail https://whatthecommit.com/index.txt)
                git push
            case papa
                git-papa
            case p
                command git pull
            case '*'
                command git $argv
        end
    end
end

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

function git-convert
    # Get the current remote URL of the origin
    set current_url (git remote get-url origin)

    # Check if the URL starts with https
    if string match --regex --quiet "^https://" $current_url
        # Convert the https URL to ssh format
        set ssh_url (string replace "https://" "git@" $current_url)
        set ssh_url (string replace "/" ":" $ssh_url)

        # Update the remote URL to the new SSH format
        git remote set-url origin $ssh_url

        echo "Converted remote URL from HTTPS to SSH: $ssh_url"
    else
        echo "The current remote URL is not using HTTPS."
    end
end

function git-root
    command cd $(git rev-parse --show-toplevel)
end
