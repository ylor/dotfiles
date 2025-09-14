#!/bin/sh
# Usage: curl -fsSL boot.roly.sh
set -e

exist() { command -v "$1" >/dev/null; }
missing() { ! command -v "$1" >/dev/null; }
npc() {
    str="$*"
    while [ -n "$str" ]; do
        printf "%s" "${str%"${str#?}"}"
        str="${str#?}"
        sleep 0.01
    done
    sleep 0.25
    printf "\n"
}

clear
curl -fsSL art.roly.sh
npc "enter your password to continue (or abort with ctrl+c)..."
sudo true
while true; do sudo --non-interactive true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [ "$(uname)" = "Darwin" ]; then
	if missing /opt/homebrew/bin/brew; then
		bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	/opt/homebrew/bin/brew install --quiet fish git gum
fi

if [ "$(uname)" = "Linux" ] && exist pacman; then
   	sudo pacman -Sy --noconfirm --needed fish git gum # Arch
fi

eval "$(/opt/homebrew/bin/brew shellenv)"
if missing fish || missing git || missing gum; then
    echo
    npc "$(tput setaf 1)ERROR$(tput sgr0) unsupported operating system or missing dependencies"
    npc "Retry by running: fish $HOME/.local/share/struct/main.fish"
    npc "$(tput sitm)✈ YOU'RE GONNA CARRY THAT WEIGHT.$(tput ritm)"
    exit 67
fi

DOT_PATH="$HOME/.local/share/dotfiles"
rm -rf "$DOT_PATH"
npc "initializing..."
git clone https://github.com/ylor/env.git "$DOT_PATH"
fish "$DOT_PATH/main.fish"
