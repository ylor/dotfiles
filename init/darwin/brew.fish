#!/usr/bin/env fish
function strap
    info "Installing homebrew..."
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
ensure gum

# TODO: if all packages are installed, skip this step
# Install packages
set pkgs bat eza fd fzf jq mise ripgrep zoxide
set installed_pkgs (brew list --formula)
# set gum_pkgs (gum choose --header "homebrew packages" --no-limit $pkgs --selected='*')
# if test "$gum_pkgs"
for pkg in $pkgs
    echo "$installed_pkgs" | grep -iq "$pkg" || gum spin --title="brewing $pkg..." -- brew install --force $pkg
end
# end

# Install casks
# set casks 1password alt-tab appcleaner betterdisplay ghostty hyperkey linearmouse maccy zed
# set installed_casks (brew list --cask)
# set gum_casks (gum choose --header "homebrew casks" --no-limit $casks)
# if test "$gum_casks"
#     for cask in $gum_casks
#         echo "$installed_casks" | grep -iq "$cask" || gum spin --title="brewing $cask..." -- brew install --cask --force $cask
#     end
# end
