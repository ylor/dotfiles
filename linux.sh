#!/usr/bin/env bash

# Check for apt on Debian/Ubuntu
if [ -f /usr/bin/apt ]; then

  # Bootstrap Ubuntu so it can actually do literally anything
  sudo apt install build-essential curl -y

  # Add custom repositories
  ## UI
  sudo add-apt-repository ppa:daniruiz/flat-remix -y
  ## VSCode
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
  sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  ## Yarn
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

  sudo apt update
  sudo apt upgrade -y
  pkgs=(
    "exa"
    "fd-find"
    "fish"
    "flat-remix flat-remix-gnome flat-remix-gtk"
    "git"
    "gnome-tweaks"
    "nodejs"
    "ripgrep"
    "rustc cargo libssl-dev pkg-config"
    "stow"
    "yarn"
  )
  sudo apt install ${pkgs[@]} -y
  sudo apt autoremove -y
fi

# Check for dnf on Fedora
if [ -f /usr/bin/dnf ]; then

  sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  sudo dnf copr enable daniruiz/flat-remix

  # VSCode -
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'

  sudo dnf update
  sudo dnf upgrade -y
  sudo dnf groupinstall "Development Tools"
  pkgs=(
    "chsh"
    "exa"
    "fd-find"
    "fish"
    "flat-remix flat-remix-gnome flat-remix-gtk"
    "gnome-tweaks"
    "openssl-devel"
    "ripgrep"
    "rust cargo"
    "stow"
    "yarn"
  )
  sudo dnf install ${pkgs[@]} -y

  sudo curl -sL https://rpm.nodesource.com/setup_12.x | bash -
fi
