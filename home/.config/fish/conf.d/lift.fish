function lift
    argparse 'c/cycles=' 't/time=' 'h/help' -- $argv || return
    set --function cycles "5"
    set --function time "1.5m"

    if set --query --function _flag_cycles
        set cycles $_flag_cycles
    end

    if set --query --function _flag_time
        set time $_flag_time
    end

    command -vq timer || gum spin brew install caarlos0/tap/timer
    timer --name "Get Ready" 10s --fullscreen
    for i in (seq 1 $cycles)
        timer --name "Cycle $i" $time --fullscreen
    end
end
