#!/bin/sh -e
# Usage: sh -c "$(curl -fsSL boot.roly.sh)"

repo="https://github.com/ylor/env"
dest="$HOME/.local/share/env"

bold='\033[1m'
underline='\033[4m'
red='\033[31m'
green='\033[32m'
reset='\033[0m'

#[ -d $dest ] &&
rm -rf "$dest" && mkdir -p "$dest"

# echo "cloning..."
# if [ -x $(command -v git) ]; then
# 	git clone --quiet --recursive "$repo.git" "$dest"
# else
# 	curl --fail --show-error --location "$repo/archive/master.tar.gz" | tar --extract --strip-components=1 --directory "$dest"
# fi

cp -ri * "$HOME/.local/share/env"

echo "initializing..."
if [ -d "$dest" ]; then
	sh "$dest/init.sh"
	echo "${green}${bold}✓ SUCCESS"
else
	echo "${red}${bold}✗ ERROR"
	exit 1
fi
