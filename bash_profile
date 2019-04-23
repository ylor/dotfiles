#!/usr/bin/env bash

#export EDITOR='nvim'
#export VISUAL 'nvim'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Linuxbrew
test -d "$HOME/.linuxbrew" && eval $(~/.linuxbrew/bin/brew shellenv)

# Colors
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE="$(tput setaf 7)"
GRAY="$(tput setaf 8)"
NOCOLOR="$(tput sgr0)"

# Colorful ls
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
NEW_PWD=${PWD/#$HOME/\~}
# Prompt
function prompt_command() {
	first_line="$RED$(whoami)$WHITE at $YELLOW$(hostname)$WHITE in $GREEN\w"
	second_line="\`if [ \$? = 0 ]; then echo \[\$RED\]❯\[\$YELLOW\]❯\[\$GREEN\]❯; else echo \[\$RED\]❯❯❯; fi\`\\[\$WHITE\] "
	PS1="\n$first_line\n$second_line"
	PS2="\[$CYAN\]❯❯❯\[$WHITE\] "
}

prompt_command
