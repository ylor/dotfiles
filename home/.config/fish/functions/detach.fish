function detach
    fish -c "$argv" >/dev/null &
    disown
end
