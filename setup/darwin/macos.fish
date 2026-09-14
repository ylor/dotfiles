# Configure Dock
if defaults read com.apple.Dock | grep -q "com.apple.apps.launcher"
    command --query dockutil; or brew install --quiet dockutil
    dockutil --remove all --add /Applications --add "$HOME/Downloads" >/dev/null
end

# Set hostname
set -l computer_name (scutil --get ComputerName)
if string match -q "*’s*" $computer_name; and gum confirm "change computer name? current: "(string lower -- $computer_name)
    set -l new_name (gum input --prompt "new computer name: " --placeholder (string lower -- $computer_name))
    if test -n "$new_name"
        sudo scutil --set ComputerName "$new_name"
        and sudo scutil --set HostName "$new_name"
        and sudo scutil --set LocalHostName "$new_name"
        or return $status
    end
end

# Enable FileVault
if not fdesetup isactive >/dev/null 2>&1; and gum confirm "enable filevault disk encryption?"
    sudo fdesetup enable -user "$USER"
end

# Enable Firewall
if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q disabled; and gum confirm "enable application firewall?"
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
end

dfs-success "macOS"
