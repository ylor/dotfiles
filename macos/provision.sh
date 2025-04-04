#!/bin/env sh

# Prompt to set hostname
# if read -t 10 -p "Change hostname? (y/n): " response && [[ $response == [yY] ]]; then
#     # Prompt for the new hostname
#     read -p "Enter the new hostname: " name
#     echo "Hostname has been set to $name."
#     # Set computer name (as done via System Preferences → Sharing)
#     #sudo scutil --set ComputerName "0x6D746873"
#     #sudo scutil --set HostName "0x6D746873"
#     #sudo scutil --set LocalHostName "0x6D746873"
# fi

if read -t 10 -p "Clear the Dock? (y/n): " response && [[ $response == [yY] ]]; then
## clear dock
    defaults write "com.apple.dock" "persistent-apps" -array
fi

# Filevault
if $(fdesetup status | grep -q "Off.") && read -t 10 -p "Setup Filevault? (y/n): " response && [[ $response == [yY] ]]; then
        sudo fdesetup enable
fi

# Install Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if command -v brew &>/dev/null; then
    brew install --quiet bat fish gum mise tldr zoxide # fd fzf yazi
    brew install --cask --quiet 1password appcleaner betterdisplay ghostty hyperkey linearmouse maccy #alt-tab utm visual-studio-code helix zed jordanbaird-ice
fi
