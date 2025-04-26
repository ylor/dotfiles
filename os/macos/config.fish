#!/usr/bin/env fish

function ensure
    exist $argv || brew install --quiet $argv
end

ensure gum

# Install packages
set pkgs bat eza fzf hyperfine fish jq mise zoxide
set installed_pkgs (brew list --formula)
set gum_pkgs (gum choose --header "homebrew packages" --no-limit $pkgs --selected='*')
test -n "$gum_pkgs" && for pkg in $gum_pkgs
    echo "$installed_pkgs" | grep -iq "$pkg" || gum spin --title="brewing $pkg..." -- brew install --force $pkg
end

# Install casks
set casks 1password alt-tab appcleaner betterdisplay ghostty hyperkey linearmouse maccy zed
set installed_casks (brew list --formula)
set gum_casks (gum choose --header "homebrew casks" --no-limit $casks)
test -n "$gum_casks" && for cask in $gum_casks
    echo "$installed_casks" | grep -iq "$cask" || gum spin --title="brewing $cask..." -- brew install --cask --force $cask
end

# Configure dock
defaults read com.apple.Dock | grep -q "com.apple.launchpad.launcher" && gum confirm "Clear the Dock?" && begin
    ensure dockutil
    dockutil --remove all --add /Applications --add "$HOME/Downloads" >/dev/null
end

# Set hostname
gum confirm "Change hostname? (Current: '$(hostname)')" && begin
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
if test (defaults read /Library/Preferences/com.apple.alf globalstate) -ne 1 && gum confirm "Enable Firewall?"
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
end

# Configure TouchID for sudo
if test ! -f /etc/pam.d/sudo_local && bioutil --read | grep -q 1 && gum confirm "Use TouchID for sudo?"
    sed -e 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
end
