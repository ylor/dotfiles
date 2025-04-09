#!/bin/sh
set -eu

touch /Applications/Xcode.app # enable spotlight category
touch "${HOME}/.hushlogin" # shut up terminal
mkdir -p "${HOME}/Developer" # pretty finder icon

# homebrew
pkgs="bat eza fish gum mise zoxide"
gum_pkgs=$(gum choose --header "homebrew packages" --no-limit $pkgs)
[ -n "$gum_pkgs" ] && brew install "$gum_pkgs"

casks="1password alt-tab appcleaner betterdisplay ghostty hyperkey linearmouse maccy zed"
gum_casks=$(gum choose --header "homebrew casks" --no-limit $casks)
[ -n "$gum_casks" ] && brew install "$gum_casks"

# dock
if exist dockutil && defaults read com.apple.Dock | grep -q "com.apple.launchpad.launcher"; then
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

# firewall
if ! defaults read /Library/Preferences/com.apple.alf globalstate | grep -q 1 && gum confirm "Enable Firewall?"; then
	sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
fi

# touchid for sudo
if [ ! -f /etc/pam.d/sudo_local ] && bioutil --read | grep -q 1 && gum confirm "Use TouchID for sudo?"; then
	sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
fi
