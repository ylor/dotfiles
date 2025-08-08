#!/bin/sh
# Usage: sh -c "$(curl -fsSL env.roly.sh)"
# Usage: wget -O- env.roly.sh | sh
set -e

art="
   ███████ ██ ██      ███████ ███████
   ██      ██ ██      ██      ██
   █████   ██ ██      █████   ███████
   ██      ██ ██      ██           ██
██ ██      ██ ███████ ███████ ███████
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
    printf "\n"
}

printf "\033c"
echo "$art" | sed '1d'
npc "enter your password to continue (or abort with ctrl+c)..."

sudo printf
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [ "$(uname)" = "Darwin" ]; then
	if missing /opt/homebrew/bin/brew; then
		bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if missing fish || missing git || missing gum; then
	npc "Installing dependencies..."
	exist brew && brew install --quiet fish git gum # macOS
	exist pacman && sudo pacman -Sy --noconfirm --needed fish git gum # Arch
fi

devenv=$HOME/.local/share/devenv
npc "initializing..."
rm -rf "$devenv"
git clone --quiet https://github.com/ylor/env.git "$devenv" >/dev/null

cd "$devenv"
npc "installing..."
fish main.fish
