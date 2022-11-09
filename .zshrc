# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Enable redrawing of prompt variables
autoload colors && colors
setopt interactivecomments
setopt promptsubst

# Prompt symbol
COMMON_PROMPT_SYMBOL="❱"

# Colors
# COMMON_COLORS_HOST_ME=green
# COMMON_COLORS_CURRENT_DIR=magenta
# COMMON_COLORS_RETURN_STATUS_TRUE=green
# COMMON_COLORS_RETURN_STATUS_FALSE=red

# Left Prompt
PROMPT='$(common_host)$(common_current_dir)$(common_return_status)'

# Right Prompt
# RPROMPT='zsh'

# Host
common_host() {
    if [[ -n $SSH_CONNECTION ]]; then
        me="%n@%m"
    elif [[ $LOGNAME != $USER ]]; then
        me="%n"
    fi
    if [[ -n $me ]]; then
        echo "%{$fg[$COMMON_COLORS_HOST_ME]%}$me%{$reset_color%}:"
    fi
}

# Current directory
common_current_dir() {
    # [ $(echo "$SECONDS > 0.5" | bc) -eq 1 ] && echo
    # echo -n "%{$fg[$COMMON_COLORS_CURRENT_DIR]%}%~ "
    echo -n "$fg[cyan]%~"
}

# Prompt symbol
common_return_status() {
    echo "%(?.$fg[green].$fg[red]) $COMMON_PROMPT_SYMBOL%f "
}
