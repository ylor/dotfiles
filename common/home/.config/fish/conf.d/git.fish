if command -q git # https://git-scm.com
    alias ga="git add -u"
    alias gaa="git add -A"
    alias gb="git branch"
    alias gco="git checkout"
    alias gc="git clone"
    alias gp="git pull"

    function git
        set cmd $argv[1]
        set args $argv[2..]
        switch $cmd
            case b branch checkout co
                command git checkout $args; or command git checkout -b $args
            case clone
                set repo $args
                set parts (string split '/' -- $args)
                switch (count $parts)
                    case 1
                        set repo "https://github.com/ylor/$args"
                    case 2
                        set repo "https://github.com/$args"
                end
                command git clone $repo; and cd (path change-extension '' (path basename -- $repo))
            case convert
                set url (command git remote get-url origin)
                if string match -qr "^https://" $url
                    set new (string replace -r "^https://" "ssh://git@" $url)
                else if string match -qr "^ssh://" $url
                    set new (string replace -r "^ssh://git@" "https://" $url)
                else
                    echo "Unrecognized remote format."
                    return 1
                end
                command git remote set-url origin $new
                echo "Set remote to: $new"
            case lol
                command git status >/dev/null 2>&1; or return 67
                command git add -u
                command git commit -m (curl --silent --fail https://whatthecommit.com/index.txt)
                command git push
            case p
                command git pull
            case root
                cd (command git rev-parse --show-toplevel)
            case '*'
                command git $argv
        end
    end
end
