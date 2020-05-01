#!/usr/bin/env bash

# Check for apt on Debian/Ubuntu
if [ -f /usr/bin/apt ]; then

  # Bootstrap Ubuntu so it can actually do literally anything
  sudo apt install -y build-essential curl

  # Add custom repositories
  ## VSCode
  #curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >/tmp/microsoft.gpg
  #sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
  #sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  ## Yarn
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

  sudo apt update
  sudo apt -y upgrade
  pkgs=(
    "exa"
    "fd-find"
    "fish"
    "fonts-noto-color-emoji"
    "git"
    "gnome-shell-extensions gnome-tweaks"
    "lua"
    "ripgrep"
    "stow"
    "trash-cli"
    "yarn"
  )
  sudo apt -y install ${pkgs[@]}
  sudo apt -y autoremove
fi

# Check for dnf on Fedora
if [ -f /usr/bin/dnf ]; then

  # Configure extra repositories
  ## RPM Fusion
  sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

  ## VSCode -
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

  ## Yarn
  curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo

  sudo dnf -y update
  sudo dnf -y upgrade
  sudo dnf -y groupinstall "Development Tools"
  pkgs=(
    "code"
    "exa"
    "fd-find"
    "fish util-linux-user"
    "flat-remix-gnome flat-remix-gtk"
    "gnome-tweaks"
    "lua"
    "nodejs"
    "ripgrep"
    "stow"
    "trash-cli"
    "yarn"
  )
  sudo dnf -y install ${pkgs[@]}
fi

# Install Starship prompt
curl -fsSL https://starship.rs/install.sh | bash