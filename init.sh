#!/bin/sh -e
cd $(dirname $(realpath "$0"))

case $(uname) in
'Darwin')
	sh var/macos/init.sh
	sh var/macos/defaults.sh
	;;
*)
	echo "Unknown operating system. Aborting..."
	;;
esac

if [ command -v git 2>/dev/null ]; then
	payload="$HOME/.dotfiles"
	git clone --quiet "https://github.com/ylor/env" "$payload"
	sh "$payload/link.sh" >/dev/null
fi

exec fish
