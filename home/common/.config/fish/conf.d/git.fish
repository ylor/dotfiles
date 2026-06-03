if command -q git
    function git
        set -l cmd $argv[1]
        set -l args $argv[2..]

        switch $cmd
            case branch b checkout co #switch s
                command git switch $args 2>/dev/null; or command git switch --create $args

            case clone c
                set -l repo
                if string match --quiet "http*" $args[1]; or string match --quiet "git@*" $args[1]
                    set repo $args
                else if string match --quiet "*/*" $args[1]
                    set repo "https://github.com/$args"
                else
                    set repo "https://github.com/ylor/$args"
                end
                command git clone $repo; and cd (path change-extension '' (path basename -- $repo[1]))

            case convert
                set -l url (command git remote get-url origin 2>/dev/null)
                set -l new (string replace -r '^https://' 'ssh://git@' $url)
                or set new (string replace -r '^ssh://git@' 'https://' $url)
                or begin
                    echo "Unrecognized or missing remote format."
                    return 1
                end

                command git remote set-url origin $new; and echo "Set remote to: $new"

            case lol
                command git rev-parse --is-inside-work-tree >/dev/null 2>&1; or return 67
                command git add -A
                and command git commit -m (curl -sf https://whatthecommit.com/index.txt)
                and command git push

            case p
                command git pull

            case root
                # Only try to cd if the git command successfully returns a path
                builtin cd (command git rev-parse --show-toplevel 2>/dev/null); or echo "git repo not found"

            case '*'
                command git $argv
        end
    end

    alias ga="git add -u"
    alias gaa="git add -A"
    alias gb="git branch"
    alias gco="git checkout"
    alias gc="git clone"
    alias gp="git pull"
end
