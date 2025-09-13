if [ $struct_mode = minimal ]
    return
end

# Configure dock
if defaults read com.apple.Dock | grep -q "com.apple.apps.launcher"
    command -vq dockutil || brew install --quiet dockutil
    dockutil --remove all --add /Applications --add "$HOME/Downloads" >/dev/null
end

# Set hostname
if scutil --get ComputerName | grep -q "’s" && gum confirm "Change hostname? (Current: '$(hostname)')"
    set gum_hostname (gum input --placeholder (hostname))
    if test -n "$gum_hostname"
        pls scutil --set ComputerName "$gum_hostname"
        pls scutil --set HostName "$gum_hostname"
        pls scutil --set LocalHostName "$gum_hostname"
    end
end

# Enable FileVault
if fdesetup status | grep -q "Off." && gum confirm "Enable FileVault?"
    sudo fdesetup enable -user "$USER"
end

# Enable Firewall
if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q 0 && gum confirm "Enable Firewall?"
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
end

# Configure TouchID for sudo
# if test ! -e /etc/pam.d/sudo_local && gum confirm "Use TouchID for sudo?"
#     sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
# end
