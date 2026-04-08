# drop into fish for interactive shells
# adapted from https://wiki.archlinux.org/title/Fish
if [[ $(command -v fish) && "$(ps -p "$PPID" -o comm=)" != "fish" && -z ${ZSH_EXECUTION_STRING} ]]; then
   	exec fish
fi
