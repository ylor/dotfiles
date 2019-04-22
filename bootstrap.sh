#!/bin/bash

# Ask for the administrator password upfront
sudo -v

# Prestage folders for symlinking
mkdir "$HOME/.config"
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/mpv"
mkdir "$HOME/.ssh"

# Symlinks
dot="bash_profile bashrc bin config/fish/conf.d config/mpv hushlogin ssh/config tvnamer"
for file in $dot; do
	echo "Symlinking $file"
	ln -s "$(pwd)/$file" "$HOME/.$file"
done

# if macOS run below
if [ $(uname -s) = "Darwin" ]; then
  # macOS defaults
  source macos.sh

  # get the command line tools and accept the license
  xcode-select --install
  sudo xcodebuild -license accept

  # install brew
    if [ ! -f /usr/local/bin/brew ]; then
        echo "Installing Homebrew.. "
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    brew update
    brew upgrade
    brew bundle
    brew cleanup
    
    # Change shell to fish
    echo /usr/local/bin/fish | sudo tee -a /etc/shells
    chsh -s /usr/local/bin/fish
fi

# If Linux do below
if [ $(uname -s) = "Linux" ]; then
  # Check for apt on Debian/Ubuntu
  if [ -f /usr/bin/apt ]; then
    packages="build-essential gnome-tweaks git linuxbrew-wrapper"
    for pkg in $packages
      do
        sudo apt install $pkg -y
      done
    # Change shell to fish
    #echo /usr/bin/fish | sudo tee -a /etc/shells
    #chsh -s /usr/bin/fish
    #add ~/.local/bin to PATH
  fi
fi
