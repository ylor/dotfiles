#!/bin/sh
# Usage: sh -c "$(curl -fsSL boot.roly.sh)"
set -e

exist() {
    for cmd; do command -v "$cmd" >/dev/null || return 1; done
}

missing() {
    for cmd; do command -v "$cmd" >/dev/null || return 0; done
    return 1
}

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
curl -fsSL banner.roly.sh
npc "enter your password to continue (or abort with ctrl+c)..."
sudo true
while true; do sudo --non-interactive true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [ "$(uname)" = "Darwin" ]; then
	if missing /opt/homebrew/bin/brew; then
		NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"
	brew install fd fish git gum
fi

if [ "$(uname)" = "Linux" ] && exist pacman; then
   	sudo pacman -Syu --noconfirm --needed fd fish git gum # Arch
fi

if missing fd fish git gum; then
    echo
    echo "$(tput setaf 1)ERROR$(tput sgr0) Missing dependencies"
    echo "Retry by running: 'fish $HOME/.local/share/dotfiles/main.fish'"
    echo "$(tput sitm)✈ YOU'RE GONNA CARRY THAT WEIGHT.$(tput ritm)"
    exit 67
fi

DOTFILES="$HOME/.local/share/dotfiles"
rm -rf "$DOTFILES"
git clone https://github.com/ylor/dotfiles "$DOTFILES"
fish "$DOTFILES/main.fish"
