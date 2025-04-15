#!/bin/sh
# Usage: sh -c "$(curl -fsSL env.roly.sh)"
set -eu

exist() {
	command -v "$1" >/dev/null
}

success() {
	bold='\033[1m'
	green='\033[32m'
	reset='\033[0m'
	echo "${bold}${green}✓ SUCCESS${reset} $*"
}

err() {
	bold='\033[1m'
	red='\033[31m'
	reset='\033[0m'
	echo "${bold}${red}✗ ERROR${reset} $*"
	exit 1
}

npc() {
	echo $1 | while IFS="" read -r -n1 char; do
		printf "%s" "$char"
		sleep 0.01
	done
	sleep 0.5
}

clear
stty -echo -icanon time 0 min 1 # block user input
npc "hey..." && echo
npc "hey listen!" && echo
npc "it's dangerous to go alone." && printf " " && npc "take this!" && echo
npc "press any key to continue (or abort with ctrl+c)..."
stty sane # allow user input
read -t 1 -r -s # munch buffered keypresses
read -n 1 -r -s # actual prompt for keypresses


if ! exist brew; then
	! [ -d /opt/homebrew ] && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! exist git; then
	echo 'Installing git...'
	exist apt && sudo apt -y git                   # Debian / Ubuntu
	exist pacman && sudo pacman -S --noconfirm git # Arch
fi

dest="${HOME}/.local/share/env"
rm -rf "$dest"
git clone --quiet "https://github.com/ylor/env.git" "$dest"
# rm -rf "$dest" && cp -ri . "$dest"

if [ -d "$dest" ] && cd "$dest" && sh "$dest/init.sh"; then
	success "see you, space cowboy"
else
	err "you're gonna carry that weight"
fi
