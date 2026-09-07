#!/bin/sh
# Usage: sh -c "$(curl -fsSL boot.roly.sh)"
set -e

exists() {
    for cmd; do command -v "$cmd" >/dev/null || return 1; done
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
curl -fsL https://banner.roly.sh
npc "Privileged access is required. Press Ctrl-C to abort."
sudo --validate

# Keep credentials fresh until exit.
while true; do
    sudo --non-interactive --validate 2>/dev/null || true
    sleep 60
done &
sudo_keepalive=$!
trap 'kill "$sudo_keepalive" 2>/dev/null || true' EXIT

if ! exists mise; then
  curl -fsL https://mise.run | MISE_QUIET=1 sh
fi

PACKAGES="age fd fish git gum"
case "$(uname)" in
    Darwin)
        if ! exists /opt/homebrew/bin/brew; then
            NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        eval "$(/opt/homebrew/bin/brew shellenv)"
        brew install --yes $PACKAGES
        ;;
    Linux)
        . /etc/os-release
        case "$ID" in
            arch|cachyos)
                sudo pacman -Syu --noconfirm --needed $PACKAGES
                ;;
            omarchy)
                omarchy update
                omarchy pkg add $PACKAGES
                ;;
        esac
        ;;
esac

missing=
for cmd in $PACKAGES; do
    exists "$cmd" || missing="$missing $cmd"
done

if [ -n "$missing" ]; then
    printf '%s\n' "Missing required commands:$missing. Install them and rerun this script." >&2
    exit 67
fi

export DOTFILES="$HOME/.dotfiles"
rm -rf "$DOTFILES"
git clone https://github.com/ylor/dotfiles "$DOTFILES"
fish "$DOTFILES/main.fish"
