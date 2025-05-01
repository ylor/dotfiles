#!/bin/env zsh
# make homebrew happy
[[ -d /opt/homebrew ]] && eval $(/opt/homebrew/bin/brew shellenv)

# drop into fish for interactive shells
# adapted from https://wiki.archlinux.org/title/Fish
if [[ $(command -v fish) && "$(ps -p $PPID -o comm=)" != "fish" && ${SHLVL} -eq 1 && -z "${ZSH_EXECUTION_STRING}" ]]; then
    exec fish --login --interactive
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
