#!/usr/bin/env fish

# Configure dock
defaults read com.apple.Dock | grep -q "com.apple.launchpad.launcher" && gum confirm "Clear the Dock?" && begin
    ensure dockutil
    dockutil --remove all --add /Applications --add "$HOME/Downloads" >/dev/null
end

# Set hostname
gum confirm "Change hostname? (Current: '$(hostname)')"
    set gum_hostname (gum input --placeholder (hostname))
    test -n "$gum_hostname" && begin
        sudo scutil --set ComputerName "$gum_hostname"
        sudo scutil --set HostName "$gum_hostname"
        sudo scutil --set LocalHostName "$gum_hostname"
        and echo "hostname set to $gum_hostname"
        or echo "failed to set hostname"
    end
end

# Enable FileVault
if fdesetup status | grep -q "Off."
    gum confirm "Enable FileVault?" && sudo fdesetup enable -user "$USER"
end

# Enable Firewall
if test -z (defaults read /Library/Preferences/com.apple.alf globalstate)
    gum confirm "Enable Firewall?" && sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
end

# Configure TouchID for sudo
# if test ! -e /etc/pam.d/sudo_local && gum confirm "Use TouchID for sudo?"
#     sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
# end
