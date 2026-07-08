command --query dockutil; or brew install --quiet dockutil
command --query nightlight; or brew install --quiet smudge/smudge/nightlight

# Configure dock
if defaults read com.apple.Dock | grep -q "com.apple.apps.launcher"
    dockutil --remove all --add /Applications --add "$HOME/Downloads" >/dev/null
end

# Configure Night Shift
if not nightlight status | grep -qi on; and gum confirm "Enable Night Shift schedule?"
    nightlight schedule sunset; and nightlight on
end

# Set hostname
if scutil --get ComputerName | grep -q "’s"; and gum confirm "Change hostname? (Current: '$hostname')"
    set gum_hostname (gum input --placeholder $hostname)
    if test -n "$gum_hostname"
        sudo scutil --set ComputerName "$gum_hostname"
        sudo scutil --set HostName "$gum_hostname"
        sudo scutil --set LocalHostName "$gum_hostname"
    end
end

# Enable FileVault
if not fdesetup isactive >/dev/null 2>&1; and gum confirm "Enable FileVault?"
    sudo fdesetup enable -user "$USER"
end

# Enable Firewall
if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q disabled; and gum confirm "Enable Firewall?"
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
end

# Enable Screen Sharing
if not launchctl print system/com.apple.screensharing >/dev/null 2>&1; and gum confirm "Enable Screen Sharing?"
    sudo launchctl enable system/com.apple.screensharing
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
end

# Enable SSH
if sudo systemsetup -getremotelogin | grep -q "Off"; and gum confirm "Enable SSH?"
    sudo systemsetup -setremotelogin on
end

# Configure TouchID for sudo
# if test ! -e /etc/pam.d/sudo_local && gum confirm "Use TouchID for sudo?"
#     sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
# end
