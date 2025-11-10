#set --query SSH_CLIENT ||
# set --query SSH_TTY && set --global hydro_ssh "$(prompt_hostname)"
# set --global hydro_ssh
# set --query SSH_TTY && set --global hydro_ssh " $hostname"

function fish_right_prompt
    set_color black
    set -q SSH_CONNECTION SSH_TTY && echo "$(set_color black)$USER@$(set_color black)$hostname "
end
