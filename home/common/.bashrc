# drop into fish for interactive shells
# adapted from https://wiki.archlinux.org/title/Fish
[[ $SHLVL -le 2 ]] || return
[[ $(ps -p "$PPID" -o comm=) != fish ]] || return
shopt -q login_shell && exec fish --login || exec fish
