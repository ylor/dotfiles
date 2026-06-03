function bangbang # https://fishshell.com/docs/current/relnotes.html#fish-3-6-0-released-january-7-2023
    echo $history[1]
end

abbr --add !! --position anywhere --function bangbang

function _last_argument
    echo "$history[1]" | read --array --tokenize result
    echo $result[-1]
end

# Register !$ as an expanding abbreviation
abbr --add !\$ --position anywhere --function __last_argument
