#!/usr/bin/env fish

# Configure dock
if defaults read com.apple.Dock | grep -q "com.apple.launchpad.launcher"
    and gum confirm "Clear the Dock?"
    and ensure dockutil
    and dockutil --remove all --add /Applications --add "$HOME/Downloads" >/dev/null
end

# Set hostname
if gum confirm "Change hostname? (Current: '$(hostname)')"
    set gum_hostname (gum input --placeholder (hostname))
    if test -n "$gum_hostname"
        sudo scutil --set ComputerName "$gum_hostname"
        sudo scutil --set HostName "$gum_hostname"
        sudo scutil --set LocalHostName "$gum_hostname"
    end
    and echo "hostname set to $gum_hostname"
    or echo "failed to set hostname"
end

# Enable FileVault
if fdesetup status | grep -q "Off."
    gum confirm "Enable FileVault?"
    and sudo fdesetup enable -user "$USER"
end

# Enable Firewall
if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q 0 && gum confirm "Enable Firewall?"
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
end

# Configure TouchID for sudo
# if test ! -e /etc/pam.d/sudo_local && gum confirm "Use TouchID for sudo?"
#     sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
# end
