#!/usr/bin/env bash

# Check for apt on Debian/Ubuntu
if [ -f /usr/bin/apt ]; then
  sudo apt update
  sudo apt upgrade -y
  packages="build-essential curl exa fd-find file fish gnome-tweaks git nodejs npm ripgrep"
  for pkg in $packages
    do
      echo test#sudo apt install $pkg -y
    done
    sudo apt install fish
  sudo apt autoremove -y
fi
