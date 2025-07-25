#!/bin/sh
# Usage: sh -c "$(curl -fsSL env.roly.sh)"
# Usage: wget -O- env.roly.sh | sh
set -e

art="
▀█████████▄     ▄████████ ▀█████████▄   ▄██████▄     ▄███████▄
  ███    ███   ███    ███   ███    ███ ███    ███   ███    ███
  ███    ███   ███    █▀    ███    ███ ███    ███   ███    ███
 ▄███▄▄▄██▀   ▄███▄▄▄      ▄███▄▄▄██▀  ███    ███   ███    ███
▀▀███▀▀▀██▄  ▀▀███▀▀▀     ▀▀███▀▀▀██▄  ███    ███ ▀█████████▀
  ███    ██▄   ███    █▄    ███    ██▄ ███    ███   ███
  ███    ███   ███    ███   ███    ███ ███    ███   ███
▄█████████▀    ██████████ ▄█████████▀   ▀██████▀   ▄████▀
"

exist() { command -v "$1" >/dev/null; }
missing() { ! command -v "$1" >/dev/null; }

npc() {
    str="$*"
    while [ -n "$str" ]; do
        printf "%s" "${str%"${str#?}"}"
        str="${str#?}"
        sleep 0.01
    done
    sleep 0.5
}

# stty -echo -icanon time 0 min 1 # prevent ludonarrative dissonence
printf "\033[2J\033[H"
echo "$art" | sed '1d'
npc "enter your password to continue (or abort with ctrl+c)..."
echo
# dd bs=1 count=1 2>/dev/null # wait for single keypress
# stty sane
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

if missing fish || missing git || missing gum; then
	npc "Installing dependencies..."
	exist brew && brew install --quiet fish git gum         # macOS
	exist pacman && sudo pacman -S --noconfirm fish git gum # Arch
fi

devenv="$HOME/.local/share/devenv"
rm -rf "$devenv"
git clone --quiet https://github.com/ylor/env.git "$devenv" >/dev/null
# npc "Initializing..."
fish "$devenv/main.fish"
