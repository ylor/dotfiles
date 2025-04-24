#!/bin/sh
set -eu

exist() { command -v "$1" >/dev/null; }

if [ "$(command -v tput)" ]; then
	RESET="$(tput sgr0)"
	BOLD="$(tput bold)"
	RED="$(tput setaf 1)"
	GREEN="$(tput setaf 2)"
	BLUE="$(tput setaf 4)"
else
	RESET="" BOLD="" RED="" GREEN="" BLUE=""
fi

info() { printf "${BOLD}${BLUE}INFO${RESET} %s\n" "$*"; }
error() { printf "${BOLD}${RED}ERROR${RESET} %s\n" "$*" && exit 1; }
success() { printf "${BOLD}${GREEN}SUCCESS${RESET} %s\n" "$*"; }

cd "$(dirname "$0")" || error

# spin() {
# 	spinners=(line dot minidot jump pulse points meter hamburger)
# 	shuf -e "${spinners[@]}" -n 1
# }

case "$(uname)" in
"Darwin") ID="macos" ;;
"Linux") . "/etc/os-release" ;;
*) error "OS not detected or supported." ;;
esac

[ -d "os/${ID}" ] || error "'${ID}' is not a supported operating system."

for sh in "os/${ID}/"*.sh; do
	info "$sh"
	. "$sh"
done

if exist gum; then
	gum spin --title="Linking dotfiles..." -- sh link.sh
else
	sh link.sh
fi

exec fish --login --interactive
