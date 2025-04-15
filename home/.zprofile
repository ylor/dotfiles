# make homebrew happy
[[ -d /opt/homebrew ]] && eval $(/opt/homebrew/bin/brew shellenv)

# drop into fish for interactive shells
# adapted from https://wiki.archlinux.org/title/Fish
if [[ "$(uname)" == "Darwin" && $(command -v fish) && "$(ps -p $PPID -o comm=)" != "fish" && ${SHLVL} -eq 1 && -z "${ZSH_EXECUTION_STRING}" ]]; then
    exec fish --login --interactive
fi
