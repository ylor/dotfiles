function lift
    argparse c/cycles= t/time= h/help -- $argv || return

    if set --query _flag_help
        echo "Usage: lift [OPTIONS]

Options:
    -c, --cycles=NUM    Number of cycles to run (default: 5)
    -t, --time=DURATION Duration of each cycle (default: 1.5m)
    -h, --help          Show this help message"
        return 0
    end

    set cycles 5
    set time "1.5m"

    if set --query _flag_cycles
        set cycles $_flag_cycles
    end

    if set --query _flag_time
        set time $_flag_time
    end

    command -vq timer || gum spin brew install caarlos0/tap/timer
    timer --name "Get Ready" 10s --fullscreen
    for i in (seq $cycles)
        timer --name "Cycle $i" $time --fullscreen
    end
end
