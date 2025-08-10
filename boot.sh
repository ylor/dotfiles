#!/bin/sh
# Usage: curl -fsSL env.roly.sh | sh
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
    sleep 0.25
    printf "\n"
}

clear
echo "$art" | sed '1d'
npc "enter your password to continue (or abort with ctrl+c)..."
sudo --validate
while true; do sudo --non-interactive true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [ "$(uname)" = "Darwin" ]; then
	if missing /opt/homebrew/bin/brew; then
		bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"
	brew install --quiet fish git gum # macOS
fi

if [ "$(uname)" = "Linux" ] && exist pacman; then
   	sudo pacman -Sy --noconfirm --needed fish git gum # Arch
else
    exit 69
fi

devenv="$HOME/.local/share/devenv"
npc "initializing..."
rm -rf "$devenv"
rm -rf "$HOME/.local/share/devenv"
rm -rf "$HOME/.local/share/dotfiles"
rm -rf "$HOME/.local/share/env"
git clone --quiet https://github.com/ylor/env.git "$devenv"
fish "$devenv"/main.fish
