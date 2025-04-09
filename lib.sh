#!/bin/sh
set -eu

exist() {
	command -v "$1" >/dev/null
}

log() {
	if exists gum; then
		gum log "$@"
	else
		echo "$@"
	fi
}

success() {
	if exists gum; then
		gum log --prefix=SUCCESS --prefix.foreground=#32D74B "$*"
	else
		bold='\033[1m'
		green='\033[32m'
		reset='\033[0m'
		#✓
		echo "${bold}${green}SUCCESS${reset} $*"
	fi
}

err() {
	if exists gum; then
		gum log --level=error "$@"
	else
		bold='\033[1m'
		red='\033[31m'
		reset='\033[0m'
		#✗
		echo "${bold}${red}ERROR${reset} $*"
	fi
}

spin() {
	spinners=(line dot minidot jump pulse points meter hamburger)
	shuf -e "${spinners[*]}" -n 1
}
