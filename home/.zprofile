# drop into fish for interactive shells on macOS
# adapted from https://wiki.archlinux.org/title/Fish
if [[ $(uname) = "Darwin" && $(command -v fish) && $(ps -p "$PPID" -o comm=) != "fish" && -z ${ZSH_EXECUTION_STRING} && ${SHLVL} -eq 1 && -o login ]]; then
   	exec fish --login
fi
