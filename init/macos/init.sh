#!/bin/sh -e

mkdir -p "$HOME/Developer"

# homebrew
if ! exists brew; then
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
	log "dock initialized!"
fi

if gum confirm "Change hostname? (Current: '$HOSTNAME')"; then
	gum_hostname=$(gum input --placeholder "$HOSTNAME")
	if [ -n "$gum_hostname" ]; then
		sudo scutil --set ComputerName "$gum_hostname"
		sudo scutil --set HostName "$gum_hostname"
		sudo scutil --set LocalHostName "$gum_hostname"
	fi

	if [ "$HOSTNAME" = "$gum_hostname" ]; then
		success "hostname set to ${gum_hostname}"
	else
		err "failed to set hostname"
	fi
fi

if fdesetup status | grep -q "Off." && gum confirm "Enable FileVault?"; then
	sudo fdesetup enable -user "$USER" && $logger set
fi
