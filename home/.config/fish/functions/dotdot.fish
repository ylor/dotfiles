function dotdot # https://fishshell.com/docs/current/relnotes.html#fish-3-6-0-released-january-7-2023
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
