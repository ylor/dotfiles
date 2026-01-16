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
            case s
                command brew search $args
            case up
                command brew update && command brew upgrade
                detach fish_update_completions
            case formula
                command brew formulae | fzf --multi --layout reverse-list --preview 'brew info {1}' | xargs -ro brew install
            case casks
                command brew casks | fzf --multi --layout reverse-list --preview 'brew info {1}' | xargs -ro brew install
            case '*'
                command brew $argv
        end
    end
end

# if command -vq fzf
#     alias formula="brew formulae | fzf --multi --layout reverse-list --preview 'brew info {1}' | xargs -ro brew install"
#     alias casks="brew casks | fzf --multi --layout reverse-list --preview 'brew info {1}' | xargs -ro brew install"
# end
