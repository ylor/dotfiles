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
    defaults delete "com.apple.dock" "persistent-apps"
    defaults delete "com.apple.dock" "persistent-others"
    # adds folders
    for folder in "/Applications" "${HOME}/Downloads"; do
    # key:
    # <arrangement>
    #   1 -> Name
    #   2 -> Date Added
    #   3 -> Date Modified
    #   4 -> Date Created
    #   5 -> Kind
    # <displayas>
    #   0 -> Stack
    #   1 -> Folder
    # <showas>
    #   0 -> Automatic
    #   1 -> Fan
    #   2 -> Grid
    #   3 -> List
    defaults write com.apple.dock persistent-others -array-add "<dict>
            <key>tile-data</key>
            <dict>
                <key>arrangement</key>
                <integer>1</integer>
                <key>displayas</key>
                <integer>1</integer>
                <key>file-data</key>
                <dict>
                    <key>_CFURLString</key>
                    <string>file://${folder}/</string>
                    <key>_CFURLStringType</key>
                    <integer>15</integer>
                </dict>
                <key>file-type</key>
                <integer>3</integer>
                <key>showas</key>
                <integer>0</integer>
            </dict>
            <key>tile-type</key>
            <string>directory-tile</string>
        </dict>"
    done && killall Dock
fi

# Filevault
if $(fdesetup status | grep -q "Off.") && read -t 10 -p "Enable full disk encryption (Filevault 2)? (y/n): " response && [[ $response == [yY] ]]; then
        sudo fdesetup enable
fi

# Install Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if command -v brew &>/dev/null; then
    brew install bat fish gum mise tldr zoxide # fd fzf yazi
    brew install --cask 1password appcleaner betterdisplay ghostty hyperkey linearmouse maccy #alt-tab utm visual-studio-code helix zed jordanbaird-ice
fi
