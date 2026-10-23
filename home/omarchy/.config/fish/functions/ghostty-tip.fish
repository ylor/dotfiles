function ghostty-tip
    set file $HOME/.config/ghostty/local
    set line "auto-update-channel = tip"

    mkdir -p (dirname $file)
    grep --quiet --no-messages --fixed-strings --line-regexp -- $line $file; or echo $line >>$file
end
