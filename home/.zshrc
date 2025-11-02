# export PATH="$HOME/.local/bin:$PATH"

# drop into fish for interactive shells
# adapted from https://wiki.archlinux.org/title/Fish
if [[ $(uname) = "Darwin" ]]; then
    # if [[ -d /opt/homebrew ]]; then
    #     eval $(/opt/homebrew/bin/brew shellenv)
    #     export HOMEBREW_NO_AUTO_UPDATE=1
    #     export HOMEBREW_NO_ANALYTICS=1
    #     export HOMEBREW_NO_ENV_HINTS=1
    # fi

    if [[ $(command -v fish) && $(ps -p "$PPID" -o comm=) != "fish" && -z ${ZSH_EXECUTION_STRING} && ${SHLVL} == 1 && -o login ]]; then
    	exec fish --login
    fi
fi
