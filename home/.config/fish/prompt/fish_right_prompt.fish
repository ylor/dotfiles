function fish_right_prompt
    set machine (string split -m1 -f1 - $hostname)
    # set symbol ""
    # set symbol "⌘"
    # set -q SSH_CONNECTION SSH_TTY &&
    # █ ▓ ▒ ░ ⣿
    set_color black
    string lower "$USER@$machine ✦"
end
