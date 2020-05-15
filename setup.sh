#!/usr/bin/env sh

# Ask for the administrator password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# OS Check
case $(uname) in
'Darwin')
  # Install Xcode command-line tools, if not installed
  if ! xcode-select -p > /dev/null; then
    xcode-select --install > /dev/null
    sudo xcodebuild -license accept > /dev/null
  fi

  # Install Homebrew, if it's not already installed and install packages
  if ! command -v brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" && brew update && brew upgrade && brew bundle && brew cleanup

    ## packages
    brew install bash bat exa fd ffmpeg fish git lua mas media-info mkvtoolnix neovim node rename ripgrep starship tmux trash tree yarn

    ## casks
    brew cask install appcleaner hazel mpv superduper the-unarchiver visual-studio-code xld

    ## mas
    # mas asdf qwerty
  fi
  ;;
'Linux')
  # Check for apt on Debian/Ubuntu
  if command -v apt > /dev/null; then

    sudo apt update
    sudo apt -y upgrade
    sudo apt install -y bat curl fish git ripgrep trash-cli
  fi

  # Check for dnf on Fedora
  if [ -f /usr/bin/dnf ]; then
    sudo dnf -y update
    sudo dnf -y upgrade
    sudo dnf -y groupinstall "Development Tools"
    sudo dnf -y install bat fish ripgrep trash-cli
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
. link.sh

if command -v fish; then # If fish is found in $PATH

  if ! grep --quiet fish /etc/shells; then   # If fish is in PATH check for it in /etc/shells
    command -v fish | sudo tee -a /etc/shells # Add if missing
  fi

  if ! grep --quiet fish "$SHELL"; then # If fish is not the shell, make it so

    if command -v usermod; then # Ubuntu and Fedora have usermod
      sudo usermod -s "$(command -v fish)" "$(whoami)"
    else # macOS only has chsh
      sudo chsh -s "$(command -v fish)" "$(whoami)"
    fi

  fi

  command fish # Finally start fish!
else
  echo "fish was not found in PATH"
fi
