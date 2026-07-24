if command -q git; and status --is-interactive
    function git
        set cmd $argv[1]
        set args $argv[2..]

        switch $cmd
            case branch b checkout co #switch s
                command git switch $args 2>/dev/null; or command git switch --create $args

            case clone c
                set -l repo
                set -l https
                if string match --quiet "http*" $args[1]; or string match --quiet "git@*" $args[1]
                    set repo $args
                else
                    set -l spec $args[1]
                    string match --quiet "*/*" $spec; or set spec "ylor/$spec"
                    set repo "git@github.com:$spec.git" $args[2..]
                    set https "https://github.com/$spec" $args[2..]
                end
                set -l dir (string replace -r '\.git$' '' (path basename -- $repo[1]))
                command git clone $repo; and cd $dir; or begin
                    test -n "$https"; and command git clone $https; and cd $dir
                end

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
                command git commit --quiet -m (curl -sf https://whatthecommit.com/index.txt)
                command git push --quiet

            case p
                command git pull

            case root
                # Only try to cd if the git command successfully returns a path
                builtin cd (command git rev-parse --show-toplevel 2>/dev/null); or echo "git repo not found"

            case '*'
                command git $argv
        end
    end

    abbr g "git"
    abbr ga git add
    abbr gb git branch
    abbr gc git commit
    abbr gco git checkout
    abbr gf git fetch
    abbr gm git merge
    abbr gpl git pull
    abbr gpu git push
    abbr gst git status
end
