#set --query SSH_CLIENT ||
# set --query SSH_TTY && set --global hydro_ssh "$(prompt_hostname)"
# set --global hydro_ssh
# set --query SSH_TTY && set --global hydro_ssh " $hostname"

function fish_right_prompt
    set user $(string lower $USER)
    set machine $(string split . $hostname | string lower)[1]

    # set symbol ""
    # set symbol "⌘"
    # set -q SSH_CONNECTION SSH_TTY &&
    # █ ▓ ▒ ░ ⣿
    set_color black
    echo "$user@$machine ▒"
end
