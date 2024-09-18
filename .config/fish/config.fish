# Fish
set fish_greeting #disable greeting
## Syntax highlighting
set fish_color_command green
set fish_color_param normal

# Aliases
alias h="cd $HOME"
alias liberate="xattr -d com.apple.quarantine"
alias md="mkdir -p"
alias rd="rmdir"
alias re="exec fish"

# Abbreviations
abbr --add o open
abbr --add g git

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

function mdcd ### mkdir & cd to it
    mkdir $argv && cd $argv
end

## Plugins
if command -q bat # https://github.com/sharkdp/bat - modern cat
    alias cat="bat --pager=never"
end

if command -q code # https://code.visualstudio.com/ - vscode shorthand
    function c
        # test (count $argv) -eq 0 && code . || code $argv
        test (count $argv) -eq 0 && code . || code $argv
    end
end

if command -q eza # https://github.com/eza-community/eza - modern ls
    alias ls="eza"
    alias ll="ls -l"
    alias la="ls -la"
end

if command -q fzf # https://github.com/eza-community/fzf - fuzzy finder
    if command -q fd
        alias cdi="cd (fd $PWD --type d | fzf)"
    else
        alias cdi="cd (find $PWD -type d | fzf)"
    end
end

if command -q rg # https://github.com/BurntSushi/ripgrep - modern grep
    alias grep="rg"
end

if command -q zed; or command -q zed-preview # http://zed.dev - zed shorthand
    function z
        set --local zed (which zed-preview || which zed)
        test (count $argv) -eq 0 && $zed . || $zed $argv
    end
end

if command -q zoxide # https://github.com/ajeetdsouza/zoxide - smarter cd
    zoxide init fish --cmd j | source
    # alias j="z"
    # alias ji="zi"
end

# Source all .fish files found in .config/fish/plugins/
for plugin in $__fish_config_dir/plugins/**.fish
    source $plugin
end
