#!/bin/sh
set -eu

exist() {
	command -v "$1" >/dev/null
}

info() {
	bold='\033[1m'
	blue='\033[34m'
	reset='\033[0m'
	#⊙
	echo "${bold}${blue}INFO${reset} $*"
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

# spin() {
# 	spinners=(line dot minidot jump pulse points meter hamburger)
# 	shuf -e "${spinners[@]}" -n 1
# }

cd "$(dirname "$0")"

kernel=$(uname)
[ "$kernel" = "Darwin" ] && ID="macos"
[ "$kernel" = "Linux" ] && . "/etc/os-release" || err "OS not detected."
[ "$ID" ] || err "OS not detected."
[ -d "os/${ID}" ] || err "OS not supported."

for script in "os/${ID}/"*.sh; do
	info "${script}"
	. "$script"
done

if exist gum; then
	gum spin --title="Linking dotfiles..." -- sh link.sh
else
	sh link.sh
fi

exist fish && exec fish --login --interactive
