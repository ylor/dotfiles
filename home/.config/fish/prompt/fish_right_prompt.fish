function fish_right_prompt
    set -q machine || set -g machine (string split -m1 -f1 . $hostname)
    # set symbol ""
    # set symbol "⌘"
    # set -q SSH_CONNECTION SSH_TTY &&
    # █ ▓ ▒ ░ ⣿
    set_color black
    string lower "$USER@$machine ✦"
end
