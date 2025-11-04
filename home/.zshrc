# drop into fish for interactive shells
# adapted from https://wiki.archlinux.org/title/Fish
if [[ $(command -v fish) && ${SHLVL} -eq 1 && -z ${ZSH_EXECUTION_STRING} ]]; then
   	exec fish
fi