#!/bin/sh
# Usage: sh -c "$(curl -fsSL env.roly.sh)"
set -e

exist() { command -v "$1" >/dev/null; }
missing() { ! command -v "$1" >/dev/null; }

if exist tput; then
	RESET="$(tput sgr0)"
	BOLD="$(tput bold)"
	RED="$(tput setaf 1)"
	GREEN="$(tput setaf 2)"
	BLUE="$(tput setaf 4)"
fi

info() { printf "${BOLD}${BLUE}INFO${RESET} %s\n" "$*"; }
error() { printf "\r${BOLD}${RED}ERROR${RESET} %s\n" "$*" && exit 1; }
success() { printf "\r${BOLD}${GREEN}SUCCESS${RESET} %s\n" "$*"; }

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
stty -echo -icanon time 0 min 1 # prevent ludonarrative dissonence
echo " ▲"
npc "▲ ▲" && echo
npc "hey..." && npc "listen!" && echo
npc "it's dangerous to go alone." && npc " take this!" && echo
npc "press any key to continue (or abort with ctrl+c)..."
read -t 1 || read -n 1 # munch buffered keypresses and wait for real one

sudo echo
while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &

if [ "$(uname)" = "Darwin" ]; then
	if missing /opt/homebrew/bin/brew; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if missing fish || missing git; then
	info "Installing dependencies..."
	exist apk && sudo apk add fish git                  # Alpine
	exist apt && sudo apt install -y fish git           # Debian
	exist brew && brew install --quiet fish git         # macOS
	exist dnf && sudo dnf install -y fish git           # Fedora
	exist pacman && sudo pacman -S --noconfirm fish git # Arch
fi && success "Dependencies installed!"

info "Initializing..."
dest="${HOME}/.env"
rm -rf "$dest"
git clone --quiet "https://github.com/ylor/env.git" "$dest"
stty sane # allow user input
fish "${dest}/main.fish"
