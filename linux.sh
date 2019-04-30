#!/usr/bin/env bash
# Install nix if not already installed
if ! command -v nix; then
	curl https://nixos.org/nix/install | sh
fi

# Check for apt on Debian/Ubuntu
if [ -f /usr/bin/apt ]; then
  sudo apt update
  sudo apt upgrade -y
  packages="build-essential curl exa fd-find file fish gnome-tweaks git nodejs npm ripgrep"
  for pkg in $packages
    do
      echo sudo apt install "$pkg" -y
    done
  sudo apt autoremove -y
fi
