#!/usr/bin/env sh

#OS Check
case $(uname) in
'Darwin')
  #Install Homebrew, if it's not already installed and install packages
  if ! command -v brew &>/dev/null; then
    source macos/provision.sh
  fi
  source macos/defaults.sh
  ;;
*)
  echo "Unknown operating system. Aborting script."
  ;;
esac

 #Link dotfiles
sh link.sh

# if command -v fish; then #If fish is found in $PATH

#   if ! grep --quiet fish /etc/shells; then    #If fish is in $PATH check, for it in /etc/shells
#     command -v fish | sudo tee -a /etc/shells #Add if missing
#   fi

#   if ! grep --quiet fish "$SHELL"; then #If fish is not the shell, make it so
#     if command -v usermod; then         #Ubuntu and Fedora have usermod
#       sudo usermod -s "$(command -v fish)" "$(whoami)"
#     else #macOS only has chsh
#       sudo chsh -s "$(command -v fish)" "$(whoami)"
#     fi
#   fi
#   command fish #Finally start fish!
# else
#   echo "fish was not found in PATH"
# fi
