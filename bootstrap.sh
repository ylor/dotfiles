#!/usr/bin/env sh

# Ask for the administrator password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# OS Check
case $(uname) in
'Darwin')
  # Get the command line tools and accept the license, if not installed/accepted
  if ! xcode-select -p &>/dev/null; then
    xcode-select --install &>/dev/null
    sudo xcodebuild -license accept &>/dev/null
  fi

  # Install Homebrew if it's not already installed and install packages
  if ! command -v brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" && brew update && brew upgrade && brew bundle && brew cleanup

    # Brew taps
    taps=(
      beeftornado/rmtree
      homebrew/cask-fonts
    )
    for tap in "${taps[@]}"; do
      brew tap $tap
    done

    # Brew packages
    pkgs=(
      bash
      bat
      exa
      fd
      ffmpeg
      fish
      git
      lua
      mas
      media-info
      mkvtoolnix
      neovim
      node
      rename
      ripgrep
      starship
      tmux
      trash
      tree
      yarn
    )
    for pkg in "${pkgs[@]}"; do
      brew install $pkg
    done

    # Brew casks
    casks=(
      appcleaner
      hazel
      hwsensors
      keyboardcleantools
      mkvtools
      mp4tools
      mpv
      omnidisksweeper
      superduper
      the-unarchiver
      visual-studio-code
      xld
    )
    for cask in "${casks[@]}"; do
      brew cask install $cask
    done

    # mas
    # apps=(John Harry Jake Scott Philis)
    # for app in "${apps[@]}"; do
    # 	echo mas $app
    # done
  fi

  echo "Done. Note that some of these changes require a logout/restart to take effect."
  ;;
'Linux')
  # Check for apt on Debian/Ubuntu
  if [ -f /usr/bin/apt ]; then 
    sudo apt update
    sudo apt -y upgrade
    sudo apt -y install build-essential curl
    pkgs=(
      "exa"
      "fish"
      "git"
      "lua"
      "ripgrep"
      "trash-cli"
      "yarn"
    )
    sudo apt -y install ${pkgs[@]}
    sudo apt -y autoremove
  fi

  # Check for dnf on Fedora
  if [ -f /usr/bin/dnf ]; then
    sudo dnf -y update
    sudo dnf -y upgrade
    sudo dnf -y groupinstall "Development Tools"
    pkgs=(
      "exa"
      "fish util-linux-user"
      "lua"
      "nodejs"
      "ripgrep"
      "trash-cli"
      "yarn"
    )
    sudo dnf -y install ${pkgs[@]}
  fi

  # Install Starship prompt
  curl -fsSL https://starship.rs/install.sh | bash
  ;;
*)
  echo "Unknown operating system. Aborting script."
  ;;
esac

command -v npm >/dev/null && npm config set prefix "${HOME}/.npm"
command -v yarn >/dev/null && yarn config set prefix "${HOME}/.yarn"
source link.sh

if command -v fish; then
  # If fish is installed check for it in /etc/shells
  if ! grep --quiet fish /etc/shells; then
    command -v fish | sudo tee -a /etc/shells
  fi
  if ! grep --quiet fish "$SHELL"; then
    sudo chsh -s $(command -v fish) $(whoami)
  fi
  command fish
else
  echo "Fish is not installed"
fi
