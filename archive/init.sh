#!/bin/sh
set -eu

cd "$(dirname "$0")" || error

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
