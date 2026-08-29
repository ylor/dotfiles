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
npc "AUTHORIZATION REQUIRED. CTRL-C ABORTS."
sudo true
while true; do sudo --non-interactive true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [ "$(uname)" = "Darwin" ]; then
	if missing /opt/homebrew/bin/brew; then
		NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"
	brew install --yes age fd fish git gum
fi

if [ "$(uname)" = "Linux" ] && exist pacman; then
	if exist omarchy-update; then
		omarchy-update
		sudo pacman -S --noconfirm --needed age fd fish git gum # Omarchy
	else
		sudo pacman -Syu --noconfirm --needed age fd fish git gum # Arch
	fi
fi

if missing age fd fish git gum; then
    echo
    echo "░ $(tput setaf 1)DEPENDENCY FAULT$(tput sgr0) / REQUIRED SOFTWARE ABSENT" >&2
    echo "RECOVERY COMMAND / fish $HOME/.dotfiles/main.fish"
    echo "$(tput sitm)INSTALLATION HALTED / YOU'RE GONNA CARRY THAT WEIGHT.$(tput ritm)"
    exit 67
fi

export DOTFILES="$HOME/.dotfiles"
rm -rf "$DOTFILES"
git clone https://github.com/ylor/dotfiles "$DOTFILES"
fish "$DOTFILES/main.fish"
