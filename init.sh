#!/bin/env sh
set -eu
cd "$(dirname "$(realpath "$0")")"

source lib.sh

[ "$(uname)" = "Darwin" ] && ID="macos"
[ -f "/etc/os-release" ] && source "/etc/os-release"

[ -d init/"$ID" ] && for f in init/"$ID"/*.sh; do
	source "$f"
done

gum spin --spinner=$(spin) --title="Linking dotfiles..." sh link.sh
command fish
