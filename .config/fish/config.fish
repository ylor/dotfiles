# Fish
set fish_greeting #disable greeting
## Syntax highlighting
set fish_color_command green
set fish_color_param normal

# Aliases
alias g="git"
alias h="cd $HOME"
alias la="ls -la"
alias ll="ls -l"
alias md="mkdir -p"
alias re="exec fish"
alias rd="rmdir"

# Abbreviations
abbr --add o open

# Functions
function gc ### git clone && cd to it
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

function mdcd ### mkdir & cd to it
    mkdir $argv && cd $argv
end

## macOS
if test (uname) = Darwin

    # brew
    if test -d /opt/homebrew
        fish_add_path -pP /opt/homebrew/bin /opt/homebrew/sbin
        set -gx HOMEBREW_NO_ANALYTICS 1
    end

    if command -q brew
        alias b="brew"
        alias bi="brew install"
        alias binfo="brew info"
        alias bs="brew search"
        alias bu="brew uninstall"
        alias bup="brew update && brew upgrade"
    end

    # macOS Aliases
    # alias dscleanup="find $HOME -name '.DS_Store' -delete 2>/dev/null"
    # alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
    # alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
    # alias showhidden="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"

    # macOS Functions
    function cdf
        cd (osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
    end

    function vnc
        open "vnc://$argv"
    end
end

## Plugins
if command -q bat #Replaces cat with bat - https://github.com/sharkdp/bat
    alias cat="bat --pager=never"
end

if command -q code #Shortcut for vscode
    function c ### git clone && cd to it
        if test (count $argv) -eq 0
            code .
        else
            code $argv
        end
    end
end

if command -q eza #Replaces ls with eza - https://github.com/eza-community/eza
    alias ls="eza"
end

# if command -q pnpm #Replaces npm with pnpm - https://pnpm.io/
#     alias npm="pnpm"
# end

if command -q rg #Replaces grep with ripgrep - https://github.com/BurntSushi/ripgrep
    alias grep="rg"
end

if command -q zoxide #Autojumper - https://github.com/ajeetdsouza/zoxide
    zoxide init fish | source
    alias j="z"
    alias ji="zi"
end

# Hydro Prompt - https://github.com/jorgebucaran/hydro
set --global hydro_color_pwd cyan
set --global hydro_color_git magenta
set --global hydro_color_duration yellow
set --global hydro_color_prompt green
