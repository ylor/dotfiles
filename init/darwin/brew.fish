#!/usr/bin/env fish
function strap
    npc "Installing homebrew..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    set --global --export HOMEBREW_NO_ANALYTICS 1
    set --global --export HOMEBREW_NO_ENV_HINTS 1
end

function ensure
    exist $argv || brew install --quiet $argv
end

# homebrew
exist /opt/homebrew/bin/brew || strap
/opt/homebrew/bin/brew shellenv | source
exist gum || brew install --quiet gum

# Install packages
set pkgs bat evil-helix eza fd fzf jq mas mise ripgrep zoxide
set installed_pkgs (brew list --formula)
for pkg in $pkgs
    if not echo "$installed_pkgs" | grep -iq "$pkg"
        gum spin --spinner=(spinner) --title="brewing $pkg..." -- brew install --quiet $pkg
    end
end

# Install casks
set casks 1password alt-tab appcleaner betterdisplay ghostty hammerspoon hyperkey linearmouse maccy zed
set installed_casks (brew list --cask)
for cask in $casks
    if not echo "$installed_casks" | grep -iq "$cask"
        gum spin --spinner=(spinner) --title="brewing $cask..." -- brew install --quiet $cask
    end
end

# Install Mac App Store apps
# set apps 1Password-1569813296 Noir-1592917505 Wipr-1662217862
# set installed_apps (mas list)
# for app in $apps
#     set id (string split "-" -- $app)[2]
#     set name (string split "-" -- $app)[1]
#     if not echo "$installed_apps" | grep -iq "$name"
#         gum spin --spinner=(spinner) --title="installing $name..." -- mas install "$id"
#     end
# end
