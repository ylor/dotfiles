#!/bin/sh
# Usage: sh -c "$(curl -fsSL env.roly.sh)"
set -eu

exist() {
	command -v "$1" >/dev/null
}

info() {
	bold='\033[1m'
	blue='\033[34m'
	reset='\033[0m'
	echo "${bold}${blue}INFO${reset} $*"
}

success() {
	bold='\033[1m'
	green='\033[32m'
	reset='\033[0m'
	echo "${bold}${green}SUCCESS${reset} $*"
}

err() {
	bold='\033[1m'
	red='\033[31m'
	reset='\033[0m'
	echo "${bold}${red}ERROR${reset} $*"
	exit 1
}

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
	if ! [ -x /opt/homebrew/bin/brew ]; then
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
info "Cloning..."
rm -rf "$dest"
git clone --quiet "https://github.com/ylor/env.git" "$dest"

info "Initializing..."
if [ -d "$dest" ] && cd "$dest" && sh "$dest/init.sh"; then
	success "see you, space cowboy"
else
	err "you're gonna carry that weight"
fi

stty sane # allow user input
