 #set --query SSH_CLIENT ||
 # set --query SSH_TTY && set --global hydro_ssh "$(prompt_hostname)"
 set --global hydro_ssh
 set --query SSH_TTY && set --global hydro_ssh " $hostname"

function fish_right_prompt
    # set_color black && echo -n "" && hostname
    # echo ""
    set --query SSH_TTY && set_colo black && hostname
end
