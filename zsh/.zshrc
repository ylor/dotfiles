#!/usr/bin/env bash

#export EDITOR='nvim'
#export VISUAL 'nvim'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

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

# if command -v starship; then
#     PROMPT="$(
#         printf "\n${RED}ZSH"
#         starship prompt --status=$?
#     )"
# fi

PROMPT="
${CYAN}${PWD} ${NOCOLOR}via ${RED}BASH
${GREEN}❯${NOCOLOR} "
