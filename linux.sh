#!/usr/bin/env bash

# Check for apt on Debian/Ubuntu
if [ -f /usr/bin/apt ]; then

  # Bootstrap Ubuntu so it can actually do literally anything
  sudo apt install build-essential curl -y

  # Add custom repositories
  sudo add-apt-repository ppa:daniruiz/flat-remix -y
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

  sudo apt update
  sudo apt upgrade -y
  packages=(
    exa
    fd-find
    fish
    flat-remix flat-remix-gnome flat-remix-gtk
    git
    gnome-tweaks
    libssl-devel
    nodejs
    pkg-config
    ripgrep
    rustc cargo
    stow
    yarn
  )
  for pkg in $packages; do
    sudo apt install "$pkg" -y
  done
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
  packages=(
    chsh
    exa
    fd-find
    fish
    flat-remix flat-remix-gnome flat-remix-gtk
    gnome-tweaks
    openssl-devel
    ripgrep
    rust cargo
    stow
    yarn
  )
  for pkg in $packages; do
    sudo dnf install "$pkg" -y
  done

  sudo curl -sL https://rpm.nodesource.com/setup_12.x | bash -
fi
