function cdf
    cd (osascript -e 'tell application "Finder" to POSIX path of (target of window 1 as alias)')
end

function vnc
    open "vnc://$argv"
end

if test (uname) = Darwin

    # brew
    if test -d /opt/homebrew
        fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
        set -gx HOMEBREW_NO_ANALYTICS 1
    end

    if command -q brew
        abbr --add b brew
        alias bi="brew install"
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
end