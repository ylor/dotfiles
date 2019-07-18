#!/usr/bin/env bash

# Prestage folders for symlinking
folders=".config .config/fish .config/mpv .npm .ssh .yarn"
for folder in $folders; do
  mkdir -p "$HOME/$folder"
done

# Symlinks
dot="bash_profile bashrc bin config/fish config/mpv hushlogin ssh/config tvnamer zshrc"
for file in $dot; do
  echo "Symlinking $file"
  ln -sf "$(pwd)/$file" "$HOME/.$file"
done

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

if command -v npm >/dev/null; then
  npm config set prefix "${HOME}/.npm"
fi

if command -v yarn >/dev/null; then
  yarn config set prefix "${HOME}/.yarn"
fi

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
