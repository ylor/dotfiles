set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_ENV_HINTS 1

for path in /opt/homebrew /home/linuxbrew/.linuxbrew
    test -d $path && "$path/bin/brew" shellenv | source
end

if command -q brew
    function brew
        set cmd $argv[1]
        set args $argv[2..]

        switch $cmd
            case i
                command brew install $args
            case u
                command brew uninstall $args
            case re
                command brew reinstall $args
            case list ls
                if command -q tv
                    if set -q args[1]
                        tv brew --input $args[1]
                    else
                        tv brew
                    end
                else
                    command brew list $args
                end
            case search s
                if command -q tv
                    if set -q args[1]
                        tv brew-packages --input $args[1]
                    else
                        tv brew-packages
                    end
                else
                    command brew search $args
                end
            case up
                command brew update && command brew upgrade
            case '*'
                command brew $argv
        end
    end

    alias bi="brew i"
    alias bls="brew ls"
    alias brm="brew uninstall"
    alias bs="brew s"
    alias bu="brew u"
    alias bup="brew up"
end
