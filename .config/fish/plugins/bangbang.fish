function last_history_item # https://fishshell.com/docs/current/relnotes.html#fish-3-6-0-released-january-7-2023
    echo $history[1]
end

abbr -a !! --position anywhere --function last_history_item
