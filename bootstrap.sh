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

if command -v cargo >/dev/null; then
  if [ ! -f "$HOME/.cargo/bin/cargo-update" ]; then
    cargo install cargo-update
  fi

  if [ ! -f "$HOME/.cargo/bin/pazi" ]; then
    cargo install pazi
  fi

  if [ ! -f "$HOME/.cargo/bin/starship" ]; then
    cargo install starship
  fi
fi

command -v npm >/dev/null && npm config set prefix "${HOME}/.npm"

if command -v yarn >/dev/null; then
  yarn config set prefix "${HOME}/.yarn"
  yarn global add gatsby-cli npm-check-updates
fi

command -v stow >/dev/null && source link.sh

if command -v fish; then
  # If fish is installed check for it in /etc/shells
  if ! grep -q fish /etc/shells; then
    command -v fish | sudo tee -a /etc/shells
  fi
  if ! grep -q fish "$SHELL"; then
    sudo chsh -s $(command -v fish) $(whoami)
  fi
  command fish
else
  echo "Fish is not installed"
fi
