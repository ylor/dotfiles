#!/bin/sh -e

mkdir -p "$HOME/Developer"
touch "$HOME"/.hushlogin

# homebrew
if ! command -v brew 2>/dev/null ; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > /Users/roly/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
	brew install fish gum
fi

# dock
if defaults read com.apple.Dock | grep -q "com.apple.launchpad.launcher"; then
    dockutil --remove all \
	--add "/Applications" \
	--add "~/Downloads" >/dev/null
fi

if gum confirm "Change hostname? (Current: '$HOSTNAME')"; then
	gum_hostname=$(gum input --placeholder "$HOSTNAME")
	if [ -n "$gum_hostname" ]; then
		sudo scutil --set ComputerName "$gum_hostname"
		sudo scutil --set HostName "$gum_hostname"
		sudo scutil --set LocalHostName "$gum_hostname"
	fi
fi

if fdesetup status | grep -q "Off." && gum confirm "Enable FileVault?"; then
	sudo fdesetup enable -user "$USER"
fi
