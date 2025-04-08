#!/bin/sh -e
cd $(dirname $(realpath "$0"))

source lib.sh

case $(uname) in
'Darwin')
	source init/macos/init.sh
	source init/macos/defaults.sh
	;;
*)
	echo "Unknown operating system. Aborting..."
	;;
esac

# sh link.sh
# exec fish
