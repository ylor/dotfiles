## Mac Specific
if test (uname) = Darwin
  function fish_title; echo; end

  alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
  alias dscleanup="sudo find / -name '*.DS_Store' -type f -ls -delete"
  alias etrash="sudo rm -rfv /Volumes/*/.Trashes && sudo rm -rfv ~/.Trash && sudo rm -rfv /private/var/log/asl/*.asl"
  alias flush="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
  alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
  alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
  alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
  alias vnc="open vnc://Server.local"
  
  function cdf
    cd (osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
  end
end
