#!/usr/bin/env bash
# Ask for the administrator password upfront
#sudo -v
# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
#while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  # Check for apt on Debian/Ubuntu
if [ -f /usr/bin/apt ]; then
  sudo apt update
  sudo apt upgrade -y
  packages="build-essential curl exa fd-find file fish gnome-tweaks git nodejs npm ripgrep"
  for pkg in $packages
    do
      sudo apt install $pkg -y
    done
  sudo apt autoremove -y
  #chsh -s $(which fish)
fi
fish
