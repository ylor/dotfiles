#!/usr/bin/env bash

# Check for apt on Debian/Ubuntu
if [ -f /usr/bin/apt ]; then
  sudo add-apt-repository ppa:daniruiz/flat-remix
  sudo apt update
  sudo apt upgrade -y
  packages="build-essential curl exa fd-find fish flat-remix flat-remix-gnome flat-remix-gtk gnome-tweaks git ripgrep"
  for pkg in $packages; do
    sudo apt install "$pkg" -y
  done
  sudo apt autoremove -y

  curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs
fi

# Check for dnf on Fedora
if [ -f /usr/bin/dnf ]; then
  sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  sudo dnf copr enable daniruiz/flat-remix
  sudo dnf update
  sudo dnf upgrade -y
  packages="chsh exa fd-find file fish flat-remix flat-remix-gnome flat-remix-gtk gnome-tweaks ripgrep"
  for pkg in $packages; do
    sudo dnf install "$pkg" -y
  done
  sudo apt autoremove -y

  curl -sL https://rpm.nodesource.com/setup_12.x | bash -
fi
