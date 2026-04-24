function bangbang # https://fishshell.com/docs/current/relnotes.html#fish-3-6-0-released-january-7-2023
    echo $history[1]
end

abbr --add !! --position anywhere --function bangbang

function bangbangbang
    history | grep -m1 ' ' | cut -d' ' -f2-
end

abbr --add !!! --position anywhere --function bangbangbang
