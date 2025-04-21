#!/bin/sh
cd "$(dirname "$0")"

exist() { command -v "$1" >/dev/null; }

if exist tput; then
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

# spin() {
# 	spinners=(line dot minidot jump pulse points meter hamburger)
# 	shuf -e "${spinners[@]}" -n 1
# }

kernel=$(uname)
[ "$kernel" = "Darwin" ] && ID="macos"
[ "$kernel" = "Linux" ] && . "/etc/os-release"
[ "$ID" ] || err "OS not detected."
[ -d "os/${ID}" ] || err "OS not supported."

case "$kernel" in
   	Darwin) ID="macos" ;;
	Linux) . "/etc/os-release" ;;
	*) error "OS not detected."
esac
[ "$ID" ] || error "OS not detected."
ID="adsfaf"
[ -d "os/${ID}" ] || error "'${ID}' is not a supported operating system."

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
