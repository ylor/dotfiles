#!/bin/sh
set -eu

exist() { command -v "$1" >/dev/null; }

# homebrew
if ! exist brew; then
	if ! exist "/opt/homebrew/bin/brew"; then
		info 'Installing homebrew...'
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew install --quiet gum
pkgs="bat eza fzf hyperfine fish jq mise zoxide"
gum_pkgs=$(gum choose --header "homebrew packages" --no-limit $pkgs --selected=*)
[ "$gum_pkgs" ] && for pkg in $gum_pkgs; do
	if ! brew list | grep -iq $pkg; then
		gum spin --title="brewing $pkg" -- brew install $pkg
	fi
done

casks="1password alt-tab appcleaner betterdisplay ghostty hyperkey linearmouse maccy zed"
gum_casks=$(gum choose --header "homebrew casks" --no-limit $casks)
[ "$gum_casks" ] && for cask in $gum_casks; do
	if ! brew list --cask | grep -iq $cask; then
		gum spin --title="brewing $cask" -- brew install $cask
	fi
done

# dock
brew install --quiet dockutil
if exist dockutil && defaults read com.apple.Dock | grep -q "com.apple.launchpad.launcher"; then
	dockutil --remove all --add "/Applications" --add "${HOME}/Downloads" >/dev/null
fi

# hostname
if gum confirm "Change hostname? (Current: '$HOSTNAME')"; then
	gum_hostname=$(gum input --placeholder "$HOSTNAME")
	if [ "$gum_hostname" ]; then
		sudo scutil --set ComputerName "$gum_hostname"
		sudo scutil --set HostName "$gum_hostname"
		sudo scutil --set LocalHostName "$gum_hostname"
	fi && success "hostname set to ${gum_hostname}" || err "failed to set hostname"
fi

# filevault
if fdesetup status | grep -q "Off." && gum confirm "Enable FileVault?"; then
	sudo fdesetup enable -user "$USER"
fi

# firewall
if ! defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null | grep -q 1 && gum confirm "Enable Firewall?"; then
	sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
fi

# touchid for sudo
if [ ! -f /etc/pam.d/sudo_local ] && bioutil --read | grep -q 1 && gum confirm "Use TouchID for sudo?"; then
	sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
fi
