#!/bin/sh
# Usage: sh -c "$(curl -fsSL env.roly.sh)"
set -eu

dest="${HOME}/.local/share/env"

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

clear
echo "hey" && sleep 1
echo "hello..." && sleep 1
echo "hey listen!" && sleep 1
echo "it's dangerous to go alone. take this!" && sleep 1
echo "press any key to continue (or abort with ctrl+c)..." && read -n 1 -r -s

if ! exist brew; then
    echo 'Installing homebrew...'
	exist apt && sudo apt install -y git # Debian, Ubuntu
	exist pacman && sudo pacman -S --noconfirm git # Arch
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && brew install fish gum
fi

if exist git; then
	rm -rf "$dest" && mkdir -p "$dest"
	gum spin --title "cloning..." -- git clone "https://github.com/ylor/env.git" "$dest"
	# gum spin --title "cloning..." -- cp -ri . "$dest"
else
	err "'git' is required to continue"
fi

if [ -d "$dest" ] && clear && sh "$dest/init.sh"; then
	success "see you, space cowboy"
else
	err "you're gonna carry that weight"
fi
