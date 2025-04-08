#!/bin/sh -e

mkdir -p "$HOME/Developer"
touch "$HOME"/.hushlogin
touch /Applications/Xcode.app

# homebrew
if ! exists brew; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > /Users/roly/.zprofile
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# dock
if defaults read com.apple.Dock | grep -q "com.apple.launchpad.launcher"; then
	dockutil --remove all --add "/Applications" --add "${HOME}/Downloads" >/dev/null
	log "dock initialized!"
fi

# hostname
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

# filevault
if fdesetup status | grep -q "Off." && gum confirm "Enable FileVault?"; then
	sudo fdesetup enable -user "$USER" && $logger set
fi

# touchid for sudo
if [ ! -f /etc/pam.d/sudo_local ] && bioutil --read | grep -q 1 && gum confirm "Use TouchID for sudo?"; then
	sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
fi

# firewall
if ! defaults read /Library/Preferences/com.apple.alf globalstate | grep 1 && gum confirm "Enable Firewall?"; then
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
fi
