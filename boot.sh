#!/bin/sh
# Usage: bash -c "$(curl -fsSL env.roly.sh)"
# Usage: zsh -c "$(curl -fsSL env.roly.sh)"
# Usage: sh -c "$(curl -fsSL env.roly.sh)"
set -e

exist() { command -v "$1" >/dev/null; }
missing() { ! command -v "$1" >/dev/null; }

npc() {
    newline=1
    [ "$1" = "-n" ] || [ "$1" = "--no-newline" ] && { newline=0; shift; }

    str="$*"
    while [ -n "$str" ]; do
        printf "%s" "${str%"${str#?}"}"
        str="${str#?}"
        sleep 0.01
    done

    [ "$newline" -eq 1 ] && printf "\n"
}

stty -echo -icanon time 0 min 1 # prevent ludonarrative dissonence
printf "\033[2J\033[H"
npc " ▲"
npc "▲ ▲"
npc "press any key to continue (or abort with ctrl+c)..."
dd bs=1 count=1 2>/dev/null # wait for single keypress
stty sane

sudo echo
while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &

if [ "$(uname)" = "Darwin" ]; then
	if missing /opt/homebrew/bin/brew; then
		bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if missing fish || missing git; then
	npc "Installing dependencies..."
	exist apk && sudo apk add fish git                  # Alpine
	exist apt && sudo apt install -y fish git           # Debian
	exist brew && brew install --quiet fish git         # macOS
	exist dnf && sudo dnf install -y fish git           # Fedora
	exist pacman && sudo pacman -S --noconfirm fish git # Arch
fi

dest="${HOME}/.env"
rm -rf "$dest"
git clone "https://github.com/ylor/env.git" "$dest"
npc "Initializing..."
fish "${dest}/main.fish"
