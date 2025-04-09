#!/bin/env sh
set -eu
cd "$(dirname "$(realpath "$0")")"

source lib.sh

[ "$(uname)" = "Darwin" ] && ID="macos"
[ -f "/etc/os-release" ] && source "/etc/os-release"

[ -d init/"$ID" ] && for f in init/"$ID"/*.sh; do
	source "$f"
done

echo "Linking dotfiles..."
sh link.sh
success "Linked!"
command fish
