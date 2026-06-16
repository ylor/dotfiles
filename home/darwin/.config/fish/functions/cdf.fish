function cdf
    cd (osascript -e 'tell application "Finder" to POSIX path of (target of window 1 as alias)')
end
