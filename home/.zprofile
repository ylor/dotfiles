# Drop into fish for interactive shells: adapted from https://wiki.archlinux.org/title/Fish
if [[ "$(uname)" == "Darwin" && "$(ps -p $PPID -o comm=)" != "fish" && -z "${ZSH_EXECUTION_STRING}" && ${SHLVL} -eq 1 ]]; then
    exec fish --login --interactive
fi
