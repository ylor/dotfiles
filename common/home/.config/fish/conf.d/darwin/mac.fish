if test (uname) = Darwin
    abbr o open
    alias liberate="xattr -d com.apple.quarantine"

    function cdf
        cd (osascript -e 'tell application "Finder" to POSIX path of (target of window 1 as alias)')
    end

    function open
        test (count $argv) -eq 0 && command open . || command open $argv
    end

    function vnc
        open "vnc://$argv"
    end

    function fix
        switch $argv
            case spotlight
                sudo mdutil -a -i off
                sudo mdutil -a -i on
                sudo mdutil -E
            case '*'
                return 67
        end
    end

    # macOS Aliases
    alias dsclean="find $HOME -name '.DS_Store' -delete 2>/dev/null"
    alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
    # alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
    # alias showhidden="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"

    # macOS Functions
    function mac
        command -q gum || return 127

        # set ACTION $(gum choose $OPTIONS)
        # echo $ACTION
        set OPTIONS
        set -a OPTIONS dscleanup
        set -a OPTIONS "Flush DNS"
        set -a OPTIONS hide
        set -a OPTIONS show

        switch $(gum choose $OPTIONS --header "Choose action")
            case dscleanup
                dsclean
            case "Flush DNS"
                flushdns
            case hide
                defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder
            case show
                defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder
            case *
                echo "i have no idea how you got here but i'm impressed"
                return 1
        end
    end

end
