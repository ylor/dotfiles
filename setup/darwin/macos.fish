# Configure Dock
if defaults read com.apple.Dock | grep -q "com.apple.apps.launcher"
    command --query dockutil; or brew install --quiet dockutil
    dockutil --remove all --add /Applications --add "$HOME/Downloads" >/dev/null
end

# Set hostname
set -l computer_name (scutil --get ComputerName)
if string match -q "*’s*" $computer_name; and gum confirm "Revise the default hostname? Current: $computer_name"
    set -l new_name (gum input --prompt "New hostname: " --placeholder $computer_name)
    if test -n "$new_name"
        sudo scutil --set ComputerName "$new_name"
        and sudo scutil --set HostName "$new_name"
        and sudo scutil --set LocalHostName "$new_name"
        or return $status
    end
end

# Enable FileVault
if not fdesetup isactive >/dev/null 2>&1; and gum confirm "Enable FileVault disk encryption?"
    sudo fdesetup enable -user "$USER"
end

# Enable Firewall
if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q disabled; and gum confirm "Enable the application firewall?"
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
end

# Enable Screen Sharing
# if not launchctl print system/com.apple.screensharing >/dev/null 2>&1; and gum confirm "Enable Screen Sharing?"
#     sudo launchctl enable system/com.apple.screensharing
#     sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
# end

# Configure TouchID for sudo
# if test ! -e /etc/pam.d/sudo_local && gum confirm "Use TouchID for sudo?"
#     sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
# end

dfs-success "macOS configured."
