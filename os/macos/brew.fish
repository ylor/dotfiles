#!/usr/bin/env fish

function install
    info "Installing homebrew..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
end

# homebrew
set --export HOMEBREW_NO_ANALYTICS 1
set --export HOMEBREW_NO_ENV_HINTS 1
exist /opt/homebrew/bin/brew || install
/opt/homebrew/bin/brew shellenv | source
brew install --quiet gum
