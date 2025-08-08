# make homebrew happy
if [[ -d /opt/homebrew ]]; then
    eval $(/opt/homebrew/bin/brew shellenv)
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_ENV_HINTS=1
fi

# drop into fish for interactive shells
# adapted from https://wiki.archlinux.org/title/Fish
if [[ $(command -v fish) && "$(ps -p $PPID -o comm=)" != "fish" && -z "${BASH_EXECUTION_STRING}" ]]; then
    exec fish --login --interactive
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/roly/.lmstudio/bin"
# End of LM Studio CLI section

