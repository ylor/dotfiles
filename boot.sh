#!/bin/sh
# Usage: sh -c "$(curl -fsSL env.roly.sh)"
set -eu #x

exist() { command -v "$1" >/dev/null; }

if exist tput; then
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
	echo "$1" | while IFS="" read -n 1 char; do
		printf "%s" "$char"
		sleep 0.01
	done
	sleep 0.4
}

clear
stty -echo -icanon time 0 min 1 # prevent user input to prevent ludonarrative dissonence
npc "hey..." && npc "listen!" && echo
npc "it's dangerous to go alone." && printf " " && npc "take this!" && echo
npc "press any key to continue (or abort with ctrl+c)..."
read -t 1 || read -n 1 # munch buffered keypresses and wait for real one
echo

if ! exist brew; then
	if ! exist "/opt/homebrew/bin/brew"; then
		info 'Installing homebrew...'
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! exist git; then
	info 'Installing git...'
	exist apt && sudo apt -y git                   # Debian / Ubuntu
	exist pacman && sudo pacman -S --noconfirm git # Arch
fi

dest="${HOME}/.env"
rm -rf "$dest"
info "Cloning..."
git clone --quiet "https://github.com/ylor/env.git" "$dest"
exit

if [ -f "${dest}/init.sh" ]; then
	info "Initializing..."
	sh "${dest}/init.sh"
	success "see you, space cowboy"
else
	error "you're gonna carry that weight"
fi

stty sane # allow user input
