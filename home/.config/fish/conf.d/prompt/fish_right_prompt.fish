function fish_right_prompt
    if not set -q machine
        set -g machine (string split -m1 -f1 . $hostname)
        string match -r "^PAPA" "$machine" && set machine papa
    end

    # set symbol ""
    # set symbol "⌘"
    # █ ▓ ▒ ░ ⣿
    set_color black
    string lower "$USER@$machine ✦"
end
