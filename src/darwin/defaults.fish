# https://macos-defaults.com
# https://github.com/mathiasbynens/dotfiles/blob/main/.macos
mkdir -p /Applications/Xcode.app # enable spotlight category
mkdir -p "$HOME/Developer" # pretty finder icon
touch "$HOME/.hushlogin" # shut up terminal

# Activity Monitor
## set update period to 1s
# defaults write com.apple.ActivityMonitor UpdatePeriod -int 1

# Dock
## autohide
defaults write com.apple.dock autohide -bool true
## autohide delay
defaults write com.apple.dock autohide-delay -float 0
## remove recent applications
defaults write com.apple.dock show-recents -bool false
## set minimize animation to scale
defaults write com.apple.dock mineffect -string scale
# Enable spring loading for directories
# defaults write NSGlobalDomain com.apple.springing.enabled -bool true
# Remove the spring loading delay for directories
# defaults write NSGlobalDomain com.apple.springing.delay -float 0
## enable spring loading universally
# defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Finder
## set default location of new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/Downloads/"
## show extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
## enable path bar
defaults write com.apple.finder ShowPathbar -bool true
## set list view as default
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
## set search mode to default to last used
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
## do not display warning when changing a file extension in the Finder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
## home directory is opened in the fileviewer dialog when saving a new document
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
## remove the delay when hovering the toolbar title
defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0
## avoid creating .ds_store files on network or usb volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Spotlight
defaults write com.apple.Spotlight PasteboardHistoryEnabled -bool true
defaults write com.apple.Spotlight PasteboardHistoryTimeout -int 604800
## New Siri - Golden Gate
if not defaults read "/Library/Preferences/FeatureFlags/Domain/GenerativeModels.plist" EnhancedSiriWaitlist 2>/dev/null | grep --quiet "Enabled = 0"; then
    sudo defaults write "/Library/Preferences/FeatureFlags/Domain/GenerativeModels.plist" EnhancedSiriWaitlist -dict-add Enabled -bool NO;
end

# Keyboard
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 25
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
sqlite3 ~/Library/KeyboardServices/TextReplacements.db \
    "DELETE FROM ZTEXTREPLACEMENTENTRY WHERE ZSHORTCUT = 'omw';"

# General
## Hide scrollbars when scrolling
# defaults write -g AppleShowScrollBars -string WhenScrolling

# Mouse
## disable mouse acceleration
# defaults write NSGlobalDomain com.apple.mouse.linear -bool true

# Trackpad
## three finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
## enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
## disable force touch
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool true
defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -int 0

# Mission Control
## DON'T REARRANGE MY SPACES
defaults write com.apple.dock mru-spaces -bool false

# Textedit
## set plain text as default
defaults write com.apple.TextEdit RichText -bool false
## disable smart quotes
defaults write com.apple.TextEdit SmartQuotes -bool false

# Hot Corners
## bottom right → mission control
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

# Window Management
## Drag with cmd+ctrl
# defaults write -g NSWindowS houldDragOnGesture -bool true
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# Hammerspoon
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"
defaults write org.hammerspoon.Hammerspoon MJShowMenuIconKey -int 0

# disable reopening windows after restart
defaults write com.apple.loginwindow TALLogoutSavesState -bool false

# killall Finder Dock
# dfs-success "defaults set"
