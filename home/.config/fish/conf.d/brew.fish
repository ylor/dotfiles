set --global --export HOMEBREW_NO_ANALYTICS 1
set --global --export HOMEBREW_NO_AUTO_UPDATE 1
set --global --export HOMEBREW_NO_ENV_HINTS 1
# set --global --export HOMEBREW_USE_INTERNAL_API 1

for path in /opt/homebrew "/home/linuxbrew/.linuxbrew"
    [ -d $path ] && "$path/bin/brew" shellenv | source
end

if command -vq brew # https://github.com/Homebrew/brew
    alias bi="brew install"
    alias bu="brew uninstall"
    alias bs="brew search"

    function brew
        set cmd $argv[1]
        set args $argv[2..-1]

        switch $cmd
            case i
                command brew install $args
            case u
                command brew uninstall $args
            case re
                command brew reinstall $args
            case search s
                if command -vq tv
                    set -l tv_args --preview-command 'brew info {1}'
                    test -n "$args[1]"; and set -a tv_args --input "$args[1]"
                    set -l selection (begin; command brew formulae; command brew casks; end | sort | tv $tv_args)
                    test -n "$selection"; and command brew install $selection
                else
                    command brew search $args
                end
            case up
                command brew update && command brew upgrade
            case '*'
                command brew $argv
        end
    end
end
