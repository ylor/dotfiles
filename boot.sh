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
echo "hey listen!" && sleep 1
echo "it's dangerous to go alone. take this!" && sleep 1
echo "press any key to continue (or abort with ctrl+c)..." && read -n 1 -r -s

if ! exist git; then
	echo 'Installing git...'
	exist apt && sudo apt -y git                   # Debian/Ubuntu
	exist pacman && sudo pacman -S --noconfirm git # Arch

	# macOS
	if exist xcode-select; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi
fi

rm -rf "$dest" && git clone "https://github.com/ylor/env.git" "$dest"
# rm -rf "$dest" && cp -ri . "$dest"

if [ -d "$dest" ] && clear && sh "$dest/init.sh"; then
	success "see you, space cowboy"
else
	err "you're gonna carry that weight"
fi
