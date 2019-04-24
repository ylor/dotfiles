#!/usr/bin/env bash

# Ask for the administrator password upfront & keep it active until script has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Prestage folders for symlinking
mkdir "$HOME/.config"
mkdir "$HOME/.config/fish"
mkdir "$HOME/.config/mpv"
mkdir "$HOME/.ssh"

# Symlinks
dot="bash_profile bashrc bin config/fish/conf.d config/mpv hushlogin ssh/config tvnamer"
for file in $dot; do
    echo "Symlinking $file"
    ln -sf "$(pwd)/$file" "$HOME/.$file"
done

# Check for operating system
case $(uname) in
  'Darwin') 
    source macos.sh
    ;;
  'Linux')
    source linux.sh
    ;;
   *)        
    echo "Unknown operating system. Aborting script." 
    ;;
esac

if command -v fish; then
	# If fish is installed check for it in /etc/shells
	if ! grep -q fish /etc/shells; then
      		echo $(command -v fish) | sudo tee -a /etc/shells
    	fi
    # If fish is in /etc/shells, change shell to it, if it's not already
	if ! grep -q fish "$SHELL"; then
		chsh -s $(command -v fish)
	fi
	command fish
else
	echo Fish is not installed
fi
