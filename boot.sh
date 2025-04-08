#!/bin/sh
# Usage: sh -c "$(curl -fsSL env.roly.sh)"

set -eu

exists() {
	command -v "$1" >/dev/null
}

success() {
	bold='\033[1m'
	green='\033[32m'
	reset='\033[0m'
	#✓
	echo "${bold}${green}SUCCESS${reset} $*"
}

err() {
	bold='\033[1m'
	red='\033[31m'
	reset='\033[0m'
	#✗
	echo "${bold}${red}ERROR${reset} $*"
	exit 1
}

# Prompt the user to press Enter to continue
echo "hey" && sleep 1
echo "hello..." && sleep 2
echo "hey listen!" && sleep 1
echo "i'm here to set up your computer" && sleep 1
echo "press any key to continue (or abort with ctrl+c)..." && read -s -n 1

if ! command -v git >/dev/null; then
	echo "Installing git..."
	case $(uname) in
	'Darwin')
		# stolen from homebrew
		xclt_tmp="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
		sudo_askpass touch "$xclt_tmp"
		xclt_pkg=$(softwareupdate -l |
			grep -B 1 "Command Line Tools" |
			awk -F"*" '/^ *\*/ {print $2}' |
			sed -e 's/^ *Label: //' -e 's/^ *//' |
			sort -V |
			tail -n1)
		softwareupdate --install "$xclt_pkg" --verbose
		rm -f "$xclt_tmp"
		;;
	'Linux')
		command -v pacman >/dev/null && sudo pacman -S --noconfirm git
		command -v apt >/dev/null && sudo apt install -y git
		;;
	*)
		err "Unknown operating system. Aborting..."
		;;
	esac
fi

if command -v git >/dev/null; then
	echo "Cloning..."
	dest="${HOME}/.local/share/env"

	rm -rf "$dest" && mkdir -p "$dest"
	# git clone --quiet --recursive "https://github.com/ylor/env.git" "$dest"
	cp -ri . "$dest"
	echo "Cloned!"
else
	err "'git' is required to continue" # and also should definitely, definitely be here by this point
fi

echo "initializing..."
if [ -d "$dest" ]; then
	sh "$dest/init.sh"
	success "they said we'd never do it"
else
	err 'uh oh'
fi
