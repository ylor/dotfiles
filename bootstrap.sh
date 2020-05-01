#!/usr/bin/env sh

# Ask for the administrator password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# OS Check
case $(uname) in
'Darwin')
  source macos.sh
  ;;
'Linux')
  source linux.sh
  ;;
*)
  echo "Unknown operating system. Aborting script."
  ;;
esac

command -v npm >/dev/null && npm config set prefix "${HOME}/.npm"
command -v yarn >/dev/null && yarn config set prefix "${HOME}/.yarn"
command -v stow >/dev/null && source link.sh

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
