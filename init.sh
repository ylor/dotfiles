#!/bin/sh -e
set -eu
cd $(dirname $(realpath "$0"))

source lib.sh

case $(uname) in
'Darwin')
	source init/macos/init.sh
	source init/macos/defaults.sh
	;;
esac

# sh link.sh
# exec fish
