# Non-interactive
[[ -z "$PS1" ]] && export PATH="$PATH:/usr/local/bin" && return 
# Interactive
[[ -n "$PS1" ]] && source ~/.bash_profile;