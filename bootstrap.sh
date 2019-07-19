#!/usr/bin/env sh

# Ask for the administrator password upfront & keep it active until script has finished
sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# Check for operating system
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

command -v cargo >/dev/null && cargo install pazi starship

command -v npm >/dev/null && npm config set prefix "${HOME}/.npm"

command -v yarn >/dev/null && yarn config set prefix "${HOME}/.yarn"

command -v stow >/dev/null && source link.sh

if command -v fish; then
  # If fish is installed check for it in /etc/shells
  if ! grep -q fish /etc/shells; then
    command -v fish | sudo tee -a /etc/shells
  fi
  if ! grep -q fish "$SHELL"; then
    chsh -s "$(command -v fish)"
  fi
  # command fish
else
  echo Fish is not installed
fi
