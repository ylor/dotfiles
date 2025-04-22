#!/bin/sh
# Usage: sh -c "$(curl -fsSL env.roly.sh)"
set -eu

exist() { command -v "$1" >/dev/null; }

if [ -x "$(command -v tput)" ]; then
	RESET="$(tput sgr0)"
	BOLD="$(tput bold)"
	RED="$(tput setaf 1)"
	GREEN="$(tput setaf 2)"
	BLUE="$(tput setaf 4)"
else
	RESET="" BOLD="" RED="" GREEN="" BLUE=""
fi

info() { printf "${BOLD}${BLUE}INFO${RESET} %s\n" "$*"; }
error() { printf "${BOLD}${RED}ERROR${RESET} %s\n" "$*" && exit 1; }
success() { printf "${BOLD}${GREEN}SUCCESS${RESET} %s\n" "$*"; }

npc() {
	str=$1
	while [ "$str" ]; do
		printf "%s" "${str%"${str#?}"}"
		sleep 0.01
		str=${str#?}
	done
	sleep 0.4
}

clear
stty -echo -icanon time 0 min 1 # prevent user input to avoid ludonarrative dissonence
echo " ▲"
npc "▲ ▲" && echo
npc "hey..." && npc "listen!" && echo
npc "it's dangerous to go alone." && printf " " && npc "take this!" && echo
npc "press any key to continue (or abort with ctrl+c)..."
read -t 1 || read -n 1 # munch buffered keypresses and wait for real one

if [ "$(uname)" = "Darwin" ]; then
	info 'Installing homebrew...'
	if [ ! -x "/opt/homebrew/bin/brew" ]; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"
	brew install --quiet fish gum
fi

if [ ! -x "$(command -v git)" ]; then
	info 'Installing git...'
	exist apt && sudo apt -y fish git                   # Debian / Ubuntu
	exist pacman && sudo pacman -S --noconfirm fish git # Arch
fi

info "Cloning..."
dest="${HOME}/.env"
rm -rf "$dest"
git clone --quiet "https://github.com/ylor/env.git" "$dest"

info "Initializing..."
if sh "${dest}/init.sh"; then
	success "see you, space cowboy"
else
	error "you're gonna carry that weight"
fi

stty sane # allow user input
