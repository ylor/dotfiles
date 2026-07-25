# drop into fish for interactive shells
# ada ted from https://wiki.archlinux.org/title/Fish
[[ $SHLVL -le 2 ]] || return
command -v fish >/dev/null || return
[[ $(ps -p "$PPID" -o comm=) != fish ]] || return
[[ -o login ]] && exec fish --login || exec fish
