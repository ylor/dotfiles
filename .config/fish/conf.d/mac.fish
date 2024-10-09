if test (uname) = Darwin
    function cdf
        cd (osascript -e 'tell application "Finder" to POSIX path of (target of window 1 as alias)')
    end

    function open
        test (count $argv) -eq 0 && command open . || command open $argv
        abbr o open
    end

    function vnc
        open "vnc://$argv"
    end

    # macOS Aliases
    # alias dscleanup="find $HOME -name '.DS_Store' -delete 2>/dev/null"
    # alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
    # alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
    # alias showhidden="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"

    # macOS Functions
end
