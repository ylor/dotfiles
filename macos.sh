#!/bin/env sh

# https://macos-defaults.com
# https://github.com/mathiasbynens/dotfiles/blob/main/.macos
# https://github.com/darrylabbate/dotfiles

# Activity Monitor
## set update period to 1s
defaults write com.apple.ActivityMonitor "UpdatePeriod" -int "1"

# Apple Intelligence
## Disable until it's useful
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "false"

# Dock
## autohide
defaults write com.apple.dock "autohide" -bool "true"
## autohide delay
defaults write com.apple.dock "autohide-delay" -float "0"
## hide recents
defaults write com.apple.dock "show-recents" -bool "false"
## clear dock
defaults write "com.apple.dock" "persistent-apps" -array
## set minimize animation to scale
defaults write com.apple.dock "mineffect" -string "scale"

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0
## enable spring loading universally
defaults write com.apple.dock "enable-spring-load-actions-on-all-items" -bool "true"

# Finder
## show extensions
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
## enable path bar
defaults write com.apple.finder "ShowPathbar" -bool "true"
## set list view as default
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"
## set search mode to default to last used
defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"
## do not display warning when changing a file extension in the Finder
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"
## home directory is opened in the fileviewer dialog when saving a new document
defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false"
## Remove the delay when hovering the toolbar title
defaults write NSGlobalDomain "NSToolbarTitleViewRolloverDelay" -float "0"
# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Keyboard
## disable accent menu & enable key repeat
defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool "false"
# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
## enable keyboard navigation
defaults write NSGlobalDomain AppleKeyboardUIMode -int "2"
## disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Mouse
## Disable mouse acceleration
defaults write NSGlobalDomain com.apple.mouse.linear -bool "true"

# Trackpad
## three finger drag
defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool "true"
## enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Mission Control
## DON'T REARRANGE MY SPACES
defaults write com.apple.dock "mru-spaces" -bool "false"

# Textedit
## set plain text as default
defaults write com.apple.TextEdit "RichText" -bool "false"
## disable autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
## disable smart quotes
defaults write com.apple.TextEdit "SmartQuotes" -bool "false"

# Hot Corners
## com.apple.dock wvous-[bl|br|tl|tr]-corner

## Possible values wvous-*-corner:
###  0: no-op
###  2: Mission Control
###  3: Show application windows
###  4: Desktop
###  5: Start screen saver
###  6: Disable screen saver
###  7: Dashboard
### 10: Put display to sleep
### 11: Launchpad
### 12: Notification Center
### 13: Lock Screen

## Possible values wvous-*-modifier
### 0: no modifier
### 524288: option
### 1048576: command
### 1573864: option + command

## Top left screen corner → Mission Control
defaults write com.apple.dock wvous-br-corner -int 2
defaults write com.apple.dock wvous-br-modifier -int 0

# Prompt to set hostname
if read -t 10 -p "Do you want to set the device hostname? (y/n): " response && [[ $response == [yY] ]]; then
    # Prompt for the new hostname
    read -p "Enter the new hostname: " name
    # Set the hostname (this will vary depending on the system, for example, on Linux)
    echo sudo hostnamectl set-hostname "$name"
    echo "Hostname has been set to $name."
    # Set computer name (as done via System Preferences → Sharing)
    #sudo scutil --set ComputerName "0x6D746873"
    #sudo scutil --set HostName "0x6D746873"
    #sudo scutil --set LocalHostName "0x6D746873"
fi

# Install Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if command -v brew &>/dev/null; then
    brew install --quiet fish mise zoxide
    brew install --cask --quiet 1password appcleaner betterdisplay ghostty linearmouse
fi

killall "Activity Monitor" "Dock" "Finder" "TextEdit"
