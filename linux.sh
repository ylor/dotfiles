#!/usr/bin/env bash

# Check for apt on Debian/Ubuntu
if [ -f /usr/bin/apt ]; then

    # Prompt for hostname change
    read -t 30 -rp "Current hostname is $(hostname). Would you like to change it?
    Please confirm within 30 seconds. [Y/n]" changeHostname
    case $changeHostname in
        [Yy][Ee][Ss]|[Yy])
            read -rp "Enter new hostname: " newHostname
            hostnamectl set-hostname $newHostname        
        ;;
        *)
        ;;
    esac

  sudo apt update
  sudo apt upgrade -y
  packages="build-essential curl exa fd-find file fish gnome-tweaks git nodejs npm ripgrep"
  for pkg in $packages
    do
      sudo apt install "$pkg" -y
    done
  sudo apt autoremove -y
fi
