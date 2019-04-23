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
    ln -s "$(pwd)/$file" "$HOME/.$file"
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
