# Environment
set -x EDITOR 'vi'
set -x VISUAL 'code'
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8
set fish_greeting
#set fish_title

# Colors for syntax highlighting
set fish_color_command green
#set fish_color_quote yellow
#set fish_color_redirection purple
#set fish_color_end green
#set fish_color_error red
set fish_color_param normal
#set fish_color_comment blue
#set fish_color_match cyan
#set fish_color_search_match purple
#set fish_color_operator cyan
#set fish_color_escape cyan
#set fish_color_cwd green
#set fish_color_cwd_root red
#set fish_pager_color_prefix cyan
#set fish_pager_color_completion blue
#set fish_pager_color_description yellow
#set fish_pager_color_progress cyan

# Add binary folders to PATH
for bin in ~/bin ~/.bin ~/.npm/bin ~/.yarn/bin ~/.cargo/bin
    test -d $bin && set PATH $bin $PATH
end

# Aliases
alias ..="cd .."
alias ...="cd ../.."
alias fucking="sudo"
alias home="cd $HOME"
alias http="python -m SimpleHTTPServer"
alias md="mkdir -p"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
alias reboot="sudo shutdown -r now"
alias reload="exec fish"
alias shutdown="sudo shutdown -s now"
alias rd="rmdir"

# Abbreviations
abbr g 'git'
abbr ga 'git add -A;'
abbr gcm 'git commit -m'
abbr gp 'git pull'
abbr gpsh 'git push'
abbr h 'home'
abbr o 'open'
abbr u 'update'
abbr uf 'update-full'
abbr v 'vim'

# Prompt - https://starship.rs
if command -vq starship
    starship init fish | source
end

## Utility Replacements if available
if command -vq exa # Replaces ls with exa - https://github.com/ogham/exa
    alias la="exa -la"
    alias ll="exa -l"
    alias ls="exa"
end

if command -vq htop # Replaces top with htop - https://github.com/hishamhm/htop
    alias top="htop"
end

if command -vq rg # Replaces grep with ripgrep - https://github.com/BurntSushi/ripgrep
    alias grep="rg"
end

if command -vq nvim # Replaces vi(m) with neovim - https://github.com/neovim/neovim
    alias vi="nvim"
    alias vim="nvim"
end

if command -vq zoxide # Autojumper - https://github.com/ajeetdsouza/zoxide
    zoxide init fish --cmd j | source
end

# Functions
function gc ### git clone && cd to it
    if test (echo "$argv" | awk -F "/" '{print NF-1}') >/dev/null -eq 0
        git clone --recurse-submodules "https://github.com/ylor/$argv"
    else if test (echo "$argv" | awk -F "/" '{print NF-1}') >/dev/null -eq 1
        git clone --recurse-submodules "https://github.com/$argv"
    else
        git clone --recurse-submodules "$argv"
    end
    cd (basename $argv)
end

function mdcd ### mkdir & cd to it
    mkdir $argv && cd $argv
end

## Mac Specific
if test (uname) = Darwin
    function fish_title
        echo
    end

    alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
    alias dscleanup="sudo find / -name '*.DS_Store' -type f -ls -delete"
    alias flush="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
    alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
    alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
    alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
    alias vnc="open vnc://Server.local"

    function cdf
        cd (osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
    end
end

function ff # function that wraps ffmpeg
    if test (count $argv) -lt 2
        echo "Please specify either AAC, AC3, or FLAC and provide input(s)" && return 1
    else if string match --quiet --ignore-case --regex 'aac|ac3|flac' $argv[1]
        set argv[1] (string lower $argv[1])

        switch $argv[1]
            case 'aac'
                set aencoder aac_at -aq 7
            case 'ac3'
                set aencoder eac3 -ab 640k
            case 'flac'
                set aencoder flac
        end

        set --erase argv[1]

        if test (count $argv) -eq 1
            set -l output (basename $argv .mkv).conv.mkv
            echo $argv
            echo $acodec
            echo $output
            ffmpeg -i $argv -map 0 -codec copy -acodec $aencoder $output
            #and trash $argv; and mv $output $argv
        else

            for input in $argv
                set -l output (basename $input .mkv).conv.mkv
                ffmpeg -i $input -map 0 -codec copy -acodec $aencoder $output
                #and trash $input; and mv $output $input
            end

        end
    else
        echo "Please specify either AAC, AC3, or FLAC" && return 1
    end
end
